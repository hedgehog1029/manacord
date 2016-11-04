defmodule Manacord.Entity.User do
	defstruct [:id, :username, :discriminator, :avatar, :bot, :mfa_enabled, :verified, :email]
end

defmodule Manacord.Entity.UnavailableGuild do
	defstruct [:id, :unavailable]
end

defmodule Manacord.Entity.Role do
	defstruct [:id, :name, :color, :hoist, :position, :permissions, :managed, :mentionable]
end

defmodule Manacord.Entity.GuildMember do
	defstruct [{:user, %Manacord.Entity.User{}}, :nick, {:roles, []}, :joined_at, :deaf, :mute]
end

defmodule Manacord.Entity.Emoji do
	defstruct [:id, :name, {:roles, []}, :require_colons, :managed]
end

defmodule Manacord.Entity.Channel do
	defstruct [:id, :guild_id, :name, :type, :position, :is_private, :permission_overwrites, :topic, :last_message_id, :bitrate, :user_limit, :unavailable]
end

defmodule Manacord.Entity.Guild do
	defstruct [:id, :name, :icon, :splash, :owner_id, :region,
	:afk_channel_id, :afk_timeout, :embed_enabled, :embed_channel_id,
	:verification_level, :default_message_notifications, {:roles, [%Manacord.Entity.Role{}]}, {:emojis, [%Manacord.Entity.Emoji{}]},
	:features, :mfa_level, :joined_at, :large, :member_count, :voice_states,
	{:members, [%Manacord.Entity.GuildMember{}]}, {:channels, [%Manacord.Entity.Channel{}]}, :presences, :permissions, :unavailable]
end

defmodule Manacord.Entity.Attachment do
	defstruct [:id, :filename, :size, :url, :proxy_url, :height, :width]
end

defmodule Manacord.Entity.Embed.Thumbnail do
	defstruct [:url, :proxy_url, :height, :width]
end

defmodule Manacord.Entity.Embed.Video do
	defstruct [:url, :height, :width]
end

defmodule Manacord.Entity.Embed.Image do
	defstruct [:url, :proxy_url, :height, :width]
end

defmodule Manacord.Entity.Embed.Provider do
	defstruct [:name, :url]
end

defmodule Manacord.Entity.Embed.Author do
	defstruct [:name, :url, :icon_url, :proxy_icon_url]
end

defmodule Manacord.Entity.Embed.Footer do
	defstruct [:text, :icon_url, :proxy_icon_url]
end

defmodule Manacord.Entity.Embed.Field do
	defstruct [:name, :value, :inline]
end

defmodule Manacord.Entity.Embed do
	defstruct [:title, :type, :description, :url, :timestamp, :color,
	{:footer, %Manacord.Entity.Embed.Footer{}}, {:image, %Manacord.Entity.Embed.Image{}}, {:thumbnail, %Manacord.Entity.Embed.Thumbnail{}},
	{:video, %Manacord.Entity.Embed.Video{}}, {:provider, %Manacord.Entity.Embed.Provider{}}, {:author, %Manacord.Entity.Embed.Author{}},
	{:fields, [%Manacord.Entity.Embed.Field{}]}]
end

defmodule Manacord.Entity.Message do
	defstruct [:id, :channel_id, {:author, %Manacord.Entity.User{}}, :content,
	:timestamp, :edited_timestamp, :tts, :mention_everyone, {:mentions, [%Manacord.Entity.User{}]},
	:mention_roles, {:attachments, [%Manacord.Entity.Attachment{}]}, {:embeds, [%Manacord.Entity.Embed{}]},
	:nonce, :pinned, :webhook_id, :deleted]
end
