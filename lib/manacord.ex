# TODO: HTTP abstraction, see net/rest.ex

defmodule Manacord do
	def start do
		Manacord.Config.start_link()
		Manacord.Dispatcher.start_link()
	end

	def connect do
		Manacord.State.start_link()
		Manacord.Live.create_linked_socket()
	end

	def get_channel(id) when is_binary(id) do
		chan = Manacord.State.Channels.get(id)

		case chan do
			nil ->
				ch = Poison.Decode.decode Manacord.HTTP.get("channels/#{id}").body, as: %Manacord.Entity.Channel{}
				Manacord.State.Channels.update(ch.id, ch)

				ch
			ch -> ch
		end
	end

	def get_channel(%Manacord.Entity.Message{ channel_id: cid }) do
		Manacord.get_channel(cid)
	end

	def guild_for(%Manacord.Entity.Channel{ guild_id: guild_id }) do
		guild = Manacord.State.Guilds.get(guild_id)

		case guild do
			nil ->
				nil # TODO: request guild information
			g -> g
		end
	end

	def guild_for(%Manacord.Entity.Message{ channel_id: cid }) do
		Manacord.get_channel(cid) |> Manacord.guild_for
	end

	def send_message(%Manacord.Entity.Channel{ id: id }, msg) do
		Manacord.HTTP.post "channels/#{id}/messages", body: Poison.encode!(%{ content: msg })
	end

	def send_message(%Manacord.Entity.Message{ channel_id: id }, msg) do
		Manacord.HTTP.post "channels/#{id}/messages", body: Poison.encode!(%{ content: msg })
	end

	def mention(%Manacord.Entity.User{ id: id }) do
		"<@#{id}>"
	end

	def mention(%Manacord.Entity.Channel{ id: id }) do
		"<##{id}>"
	end
end
