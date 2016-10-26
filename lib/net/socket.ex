defmodule Manacord.Live do
	def handle_frame({:text, response}, socket) do
		{:ok, data} = response |> Poison.decode(as: %Manacord.OP{})

		Task.start_link(fn ->
			Manacord.InternalHandler.handle_op(data, socket)
		end)

		socket |> Manacord.Live.await_msg
	end

	def handle_frame({:close, type, _}, _) do
		IO.puts "Socket closed: #{type}"
	end

	def await_msg(socket) do
		next = socket |> Socket.Web.recv!

		next |> handle_frame(socket)
	end

	def create_socket do
		url = Manacord.HTTP.get("gateway").body |> Map.get("url") |> URI.parse
		socket = Socket.Web.connect!(url.host, secure: true, path: "/?v=5&encoding=json")

		socket |> Manacord.Live.await_msg
	end

	def create_linked_socket do
		pid = spawn_link(fn ->
			Manacord.Live.create_socket()
		end)

		{:ok, pid}
	end

	def send(socket, data) do
		d = Poison.encode!(data)

		socket |> Socket.Web.send!({:text, d})
	end
end

defmodule Manacord.Live.Heartbeat do
	def send_heartbeat(socket, timeout) do
		data = Poison.encode!(%Manacord.OP{ op: 1, d: Manacord.State.get("seq") })
		socket |> Socket.Web.send({:text, data})

		socket |> Manacord.Live.Heartbeat.wait_interval(timeout)
	end

	def wait_interval(socket, timeout) do
		Process.sleep(timeout) # we should be running on an isolated process, so this should be ok

		socket |> Manacord.Live.Heartbeat.send_heartbeat(timeout)
	end
end

defmodule Manacord.InternalHandler do
	def handle_op(%Manacord.OP{op: op, d: d, s: s, t: t}, socket) do
		case op do
			0 ->
				# dispatch event, but first update seq number in state
				Manacord.State.update("seq", s)
				Manacord.InternalHandler.handle_ev(%Manacord.OP.Dispatch{op: op, d: d, s: s, t: t}, socket)
			10 ->
				hello = Poison.Decode.decode d, as: %Manacord.OP.Hello{}

				# spawn unlinked heartbeat loop
				Task.start(fn ->
					Manacord.Live.Heartbeat.wait_interval socket, hello.heartbeat_interval
				end)

				# send Identify
				Task.start_link(fn ->
					socket |> Manacord.Live.send(%Manacord.OP{ op: 2, d: %Manacord.OP.Identify{ token: Manacord.Config.get("token") }})
				end)
			11 ->
				# ignore, not sure if we can use this to check connectivity
				nil
			_ ->
				IO.puts "Unknown opcode received!"
				# Quit here? Process is linked so it would crash entire socket, hopefully forcing restart
		end
	end

	def handle_ev(%Manacord.OP.Dispatch{d: d, t: t}, socket) do
		case t do
			"READY" ->
				ready = Poison.Decode.decode d, as: %Manacord.Events.Ready{}

				Enum.each(ready.guilds, fn g ->
					Manacord.State.Guilds.put(g.id, g)
				end)

				Manacord.Dispatcher.dispatch {:ready, ready}
			"GUILD_CREATE" ->
				guild = Poison.Decode.decode d, as: %Manacord.Entity.Guild{}

				Manacord.State.Guilds.update(guild.id, Map.merge(guild, %{ unavailable: false }))
				Manacord.Dispatcher.dispatch {:guild_create, guild}
			"GUILD_UPDATE" ->
				guild = Poison.Decode.decode d, as: %Manacord.Entity.Guild{}

				Manacord.State.Guilds.update(guild.id, guild)
				Manacord.Dispatcher.dispatch {:guild_update, guild}
			"GUILD_DELETE" ->
				id = Map.get(d, "id")

				Manacord.State.Guilds.update(id, %{ unavailable: true })
				Manacord.Dispatcher.dispatch {:guild_delete, d}
			"CHANNEL_CREATE" ->
				chan = Poison.Decode.decode d, as: %Manacord.Entity.Channel{}

				Manacord.State.Channels.update(chan.id, Map.merge(chan, %{ unavailable: false }))
				Manacord.Dispatcher.dispatch {:channel_create, chan}
			"CHANNEL_UPDATE" ->
				chan = Poison.Decode.decode d, as: %Manacord.Entity.Channel{}

				Manacord.State.Channels.update(chan.id, chan)
				Manacord.Dispatcher.dispatch {:channel_update, chan}
			"CHANNEL_DELETE" ->
				chan = Poison.Decode.decode d, as: %Manacord.Entity.Channel{}

				Manacord.State.Channels.update(chan.id, %{ unavailable: true })
				Manacord.Dispatcher.dispatch {:channel_delete, chan}
			"MESSAGE_CREATE" ->
				message = Poison.Decode.decode d, as: %Manacord.Entity.Message{}

				Manacord.State.Messages.put(message.id, message)
				Manacord.Dispatcher.dispatch {:message_create, message}
			"MESSAGE_UPDATE" ->
				message = Poison.Decode.decode d, as: %Manacord.Entity.Message{}

				Manacord.State.Messages.update(message.id, message)
				Manacord.Dispatcher.dispatch {:message_update, message}
			"MESSAGE_DELETE" ->
				id = Map.get(d, "id")

				Manacord.State.Messages.update(id, %{ deleted: true })
				Manacord.Dispatcher.dispatch {:message_delete, d}
			"MESSAGE_DELETE_BULK" ->
				ids = Map.get(d, "ids")

				Enum.each(ids, fn id -> Manacord.State.Messages.update(id, %{ deleted: true }) end)
				Manacord.Dispatcher.dispatch {:message_delete_bulk, d}
			_ ->
				nil
		end
	end
end

defmodule Manacord.Dispatcher do
	def start_link do
		GenEvent.start_link name: __MODULE__
	end

	def dispatch(payload) do
		GenEvent.notify __MODULE__, payload
	end

	def attach(handler) do
		GenEvent.add_handler __MODULE__, handler, []
	end
end
