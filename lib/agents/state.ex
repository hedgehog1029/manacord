defmodule Manacord.State do
	def start_link do
		Agent.start_link(fn ->
			Map.new
		end, name: __MODULE__)

		# Start all sub-modules aswell
		# Supervision tree? If states crash we need to restart everything...
		Manacord.State.Guilds.start_link()
		Manacord.State.Channels.start_link()
		Manacord.State.Users.start_link()
		Manacord.State.Messages.start_link()
	end

	def put(key, value) do
		Agent.update(__MODULE__, &Map.put(&1, key, value))
	end

	def update(key, value) do
		Agent.update(__MODULE__, &Map.update(&1, key, value, fn _ -> value end))
	end

	def get(key) do
		Agent.get(__MODULE__, &Map.get(&1, key))
	end
end

defmodule Manacord.State.Guilds do
	def start_link do
		Agent.start_link(fn ->
			Map.new
		end, name: __MODULE__)
	end

	def put(key, value) do
		Agent.update(__MODULE__, &Map.put(&1, key, value))
	end

	def update(key, value) do
		Agent.update(__MODULE__, &Map.update(&1, key, value, fn g -> Map.merge(g, value) end))
	end

	def get(key) do
		Agent.get(__MODULE__, &Map.get(&1, key))
	end

	def delete(key) do
		Agent.update(__MODULE__, &Map.delete(&1, key))
	end
end

defmodule Manacord.State.Channels do
	def start_link do
		Agent.start_link(fn ->
			Map.new
		end, name: __MODULE__)
	end

	def put(key, value) do
		Agent.update(__MODULE__, &Map.put(&1, key, value))
	end

	def update(key, value) do
		Agent.update(__MODULE__, &Map.update(&1, key, value, fn ch -> Map.merge(ch, value) end))
	end

	def get(key) do
		Agent.get(__MODULE__, &Map.get(&1, key))
	end

	def delete(key) do
		Agent.update(__MODULE__, &Map.delete(&1, key))
	end
end

defmodule Manacord.State.Users do
	def start_link do
		Agent.start_link(fn ->
			Map.new
		end, name: __MODULE__)
	end

	def put(key, value) do
		Agent.update(__MODULE__, &Map.put(&1, key, value))
	end

	def update(key, value) do
		Agent.update(__MODULE__, &Map.update(&1, key, value, fn u -> Map.merge(u, value) end))
	end

	def get(key) do
		Agent.get(__MODULE__, &Map.get(&1, key))
	end
end

defmodule Manacord.State.Messages do
	def start_link do
		Agent.start_link(fn ->
			Map.new
		end, name: __MODULE__)
	end

	def put(key, value) do
		Agent.update(__MODULE__, &Map.put(&1, key, value))
	end

	def update(key, value) do
		Agent.update(__MODULE__, &Map.update(&1, key, value, fn m -> Map.merge(m, value) end))
	end

	def get(key) do
		Agent.get(__MODULE__, &Map.get(&1, key))
	end
end
