defmodule Manacord.OP do
	defstruct [:op, :d, :s, :t]
end

defmodule Manacord.OP.Identify do
	defstruct token: "", properties: %{ "$os" => "windows", "$browser" => "Manacord", "$device" => "Manacord" }, compress: false, large_threshold: 250
end

defmodule Manacord.OP.Dispatch do
	defstruct t: nil, s: nil, op: 0, d: nil
end

defmodule Manacord.OP.Hello do
	defstruct [:_trace, :heartbeat_interval]
end

defmodule Manacord.Events.Ready do
	defstruct v: nil,
		user: %Manacord.Entity.User{},
		private_channels: [%Manacord.Entity.Channel{}],
		guilds: [%Manacord.Entity.UnavailableGuild{}],
		session_id: nil,
		presences: nil,
		relationships: nil,
		_trace: nil
end

defmodule Manacord.Events.Resume do
	defstruct [:_trace]
end
