module Make(H : S.Http) = struct
    module Http = H
    module Activity = Activity.Make(H)
    module Attachment = Attachment.Make(H)
    module Ban = Ban.Make(H)
    module Channel = Channel.Make(H)
    module Embed = Embed.Make(H)
    module Emoji = Emoji.Make(H)
    module Guild = Guild.Make(H)
    module Member = Member.Make(H)
    module Message = Message.Make(H)
    module Presence = Presence.Make(H)
    module Reaction = Reaction.Make(H)
    module Role = Role.Make(H)
    module Snowflake = Snowflake.Make(H)
    module User = User.Make(H)
end