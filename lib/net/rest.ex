# TODO: Abstraction! Async! GenServer!

defmodule Manacord.HTTP do
	use HTTPotion.Base

	def process_url(url) do
		URI.merge("https://discordapp.com/api/", url) |> to_string
	end

	def process_request_headers(headers) do
		[
			"Authorization": "Bot #{Manacord.Config.get("token")}",
			"User-Agent": "Manacord (http://manacord.offbeatwit.ch, 0.1)",
			"Content-Type": "application/json"
		]
	end

	def process_response_body(body) do
		body |> IO.iodata_to_binary |> Poison.Parser.parse!
	end
end
