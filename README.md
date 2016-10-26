# Manacord

An Elixir library for interacting with the Discord API.
In very early alpha. Will receive messages + let you reply to them, and keeps track of some state.
Missing a lot of event handling and the REST is currently blocking, plus little abstraction over RESTful API.
Most of the structs are in though, I think you could use this to build a basic bot.

## Example

Here's an example bot that I mocked up quickly.
```elixir
Manacord.start()
Manacord.Config.setToken("[Token goes here]")

defmodule TestBotHandler do
	use GenEvent

	def handle_event({:message_create, msg}, _) do
		case msg.content do
			"^ping" ->
				msg |> Manacord.send_message("Pong!")
			_ ->
				nil
		end

		{:ok, []}
	end

	def handle_event({:ready, ready}, _) do
		IO.puts "Connected as #{ready.user.username}!"
		{:ok, []}
	end

	def handle_event(_, _) do
		{:ok, []}
	end
end

Manacord.Dispatcher.attach(TestBotHandler)

Manacord.connect()
```

## Installation

You can grab it using the github syntax right now:

  1. Add `manacord` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:manacord, github: "hedgehog1029/manacord", branch: "master"}]
    end
    ```

  2. Ensure `manacord` is started before your application:

    ```elixir
    def application do
      [applications: [:manacord]]
    end
    ```
