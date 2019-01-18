open Core

exception Invalid_event of string

type t =
| HELLO of Yojson.Safe.json
| READY of Yojson.Safe.json
| RESUMED of Yojson.Safe.json
| INVALID_SESSION of Yojson.Safe.json
| CHANNEL_CREATE of Channel_t.t
| CHANNEL_UPDATE of Channel_t.t
| CHANNEL_DELETE of Channel_t.t
| CHANNEL_PINS_UPDATE of Yojson.Safe.json
| GUILD_CREATE of Guild_t.t
| GUILD_UPDATE of Guild_t.t
| GUILD_DELETE of Guild_t.t
| GUILD_BAN_ADD of Ban_t.t
| GUILD_BAN_REMOVE of Ban_t.t
| GUILD_EMOJIS_UPDATE of Yojson.Safe.json
| GUILD_INTEGRATIONS_UPDATE of Yojson.Safe.json
| GUILD_MEMBER_ADD of Member_t.t
| GUILD_MEMBER_REMOVE of Member_t.member_wrapper
| GUILD_MEMBER_UPDATE of Member_t.member_update
| GUILD_MEMBERS_CHUNK of Member_t.t list
| GUILD_ROLE_CREATE of Role_t.t
| GUILD_ROLE_UPDATE of Role_t.t
| GUILD_ROLE_DELETE of Role_t.t
| MESSAGE_CREATE of Message_t.t
| MESSAGE_UPDATE of Message_t.message_update
| MESSAGE_DELETE of Snowflake.t * Snowflake.t
| MESSAGE_BULK_DELETE of Snowflake.t list
| MESSAGE_REACTION_ADD of Reaction_t.reaction_event
| MESSAGE_REACTION_REMOVE of Reaction_t.reaction_event
| MESSAGE_REACTION_REMOVE_ALL of Reaction_t.t list
| PRESENCE_UPDATE of Presence.t
| TYPING_START of Yojson.Safe.json
| USER_UPDATE of Yojson.Safe.json
| VOICE_STATE_UPDATE of Yojson.Safe.json
| VOICE_SERVER_UPDATE of Yojson.Safe.json
| WEBHOOKS_UPDATE of Yojson.Safe.json

let event_of_yojson ~contents t = match t with
    | "HELLO" -> HELLO contents
    | "READY" -> READY contents
    | "RESUMED" -> RESUMED contents
    | "INVALID_SESSION" -> INVALID_SESSION contents
    | "CHANNEL_CREATE" -> CHANNEL_CREATE (Channel_t.(channel_wrapper_of_yojson_exn contents |> wrap))
    | "CHANNEL_UPDATE" -> CHANNEL_UPDATE (Channel_t.(channel_wrapper_of_yojson_exn contents |> wrap))
    | "CHANNEL_DELETE" -> CHANNEL_DELETE (Channel_t.(channel_wrapper_of_yojson_exn contents |> wrap))
    | "CHANNEL_PINS_UPDATE" -> CHANNEL_PINS_UPDATE contents
    | "GUILD_CREATE" -> GUILD_CREATE (Guild_t.(pre_of_yojson_exn contents |> wrap))
    | "GUILD_UPDATE" -> GUILD_UPDATE (Guild_t.(pre_of_yojson_exn contents |> wrap))
    | "GUILD_DELETE" -> GUILD_DELETE (Guild_t.(pre_of_yojson_exn contents |> wrap))
    | "GUILD_BAN_ADD" -> GUILD_BAN_ADD (Ban_t.of_yojson_exn contents)
    | "GUILD_BAN_REMOVE" -> GUILD_BAN_REMOVE (Ban_t.of_yojson_exn contents)
    | "GUILD_EMOJIS_UPDATE" -> GUILD_EMOJIS_UPDATE contents
    | "GUILD_INTEGRATIONS_UPDATE" -> GUILD_INTEGRATIONS_UPDATE contents
    | "GUILD_MEMBER_ADD" -> GUILD_MEMBER_ADD (Member_t.of_yojson_exn contents)
    | "GUILD_MEMBER_REMOVE" -> GUILD_MEMBER_REMOVE (Member_t.member_wrapper_of_yojson_exn contents)
    | "GUILD_MEMBER_UPDATE" -> GUILD_MEMBER_UPDATE (Member_t.member_update_of_yojson_exn contents)
    | "GUILD_MEMBERS_CHUNK" -> GUILD_MEMBERS_CHUNK (Yojson.Safe.Util.to_list contents |> List.map ~f:Member_t.of_yojson_exn)
    | "GUILD_ROLE_CREATE" -> GUILD_ROLE_CREATE (let Role_t.{guild_id;role} = Role_t.role_update_of_yojson_exn contents in Role_t.wrap ~guild_id role)
    | "GUILD_ROLE_UPDATE" -> GUILD_ROLE_UPDATE (let Role_t.{guild_id;role} = Role_t.role_update_of_yojson_exn contents in Role_t.wrap ~guild_id role)
    | "GUILD_ROLE_DELETE" -> GUILD_ROLE_DELETE (let Role_t.{guild_id;role} = Role_t.role_update_of_yojson_exn contents in Role_t.wrap ~guild_id role)
    | "MESSAGE_CREATE" -> MESSAGE_CREATE (Message_t.of_yojson_exn contents)
    | "MESSAGE_UPDATE" -> MESSAGE_UPDATE (Message_t.message_update_of_yojson_exn contents)
    | "MESSAGE_DELETE" -> MESSAGE_DELETE (Yojson.Safe.Util.(member "id" contents |> Snowflake.of_yojson_exn), Yojson.Safe.Util.(member "channel_id" contents |> Snowflake.of_yojson_exn))
    | "MESSAGE_BULK_DELETE" -> MESSAGE_BULK_DELETE (Yojson.Safe.Util.to_list contents |> List.map ~f:Snowflake.of_yojson_exn)
    | "MESSAGE_REACTION_ADD" -> MESSAGE_REACTION_ADD (Reaction_t.reaction_event_of_yojson_exn contents)
    | "MESSAGE_REACTION_REMOVE" -> MESSAGE_REACTION_REMOVE (Reaction_t.reaction_event_of_yojson_exn contents)
    | "MESSAGE_REACTION_REMOVE_ALL" -> MESSAGE_REACTION_REMOVE_ALL (Yojson.Safe.Util.to_list contents |> List.map ~f:Reaction_t.of_yojson_exn)
    | "PRESENCE_UPDATE" -> PRESENCE_UPDATE (Presence.of_yojson_exn contents)
    | "TYPING_START" -> TYPING_START contents
    | "USER_UPDATE" -> USER_UPDATE contents
    | "VOICE_STATE_UPDATE" -> VOICE_STATE_UPDATE contents
    | "VOICE_SERVER_UPDATE" -> VOICE_SERVER_UPDATE contents
    | "WEBHOOKS_UPDATE" -> WEBHOOKS_UPDATE contents
    | s -> raise @@ Invalid_event s

let dispatch ev = match ev with
| HELLO d -> !Config.hello d
| READY d -> !Config.ready d
| RESUMED d -> !Config.resumed d
| INVALID_SESSION d -> !Config.invalid_session d
| CHANNEL_CREATE d -> !Config.channel_create d
| CHANNEL_UPDATE d -> !Config.channel_update d
| CHANNEL_DELETE d -> !Config.channel_delete d
| CHANNEL_PINS_UPDATE d -> !Config.channel_pins_update d
| GUILD_CREATE d -> !Config.guild_create d
| GUILD_UPDATE d -> !Config.guild_update d
| GUILD_DELETE d -> !Config.guild_delete d
| GUILD_BAN_ADD d -> !Config.member_ban d
| GUILD_BAN_REMOVE d -> !Config.member_unban d
| GUILD_EMOJIS_UPDATE d -> !Config.guild_emojis_update d
| GUILD_INTEGRATIONS_UPDATE d -> !Config.integrations_update d
| GUILD_MEMBER_ADD d -> !Config.member_join d
| GUILD_MEMBER_REMOVE d -> !Config.member_leave d
| GUILD_MEMBER_UPDATE d -> !Config.member_update d
| GUILD_MEMBERS_CHUNK d -> !Config.members_chunk d
| GUILD_ROLE_CREATE d -> !Config.role_create d
| GUILD_ROLE_UPDATE d -> !Config.role_update d
| GUILD_ROLE_DELETE d -> !Config.role_delete d
| MESSAGE_CREATE d -> !Config.message_create d
| MESSAGE_UPDATE d -> !Config.message_update d
| MESSAGE_DELETE (d,e) -> !Config.message_delete d e
| MESSAGE_BULK_DELETE d -> !Config.message_bulk_delete d
| MESSAGE_REACTION_ADD d -> !Config.reaction_add d
| MESSAGE_REACTION_REMOVE d -> !Config.reaction_remove d
| MESSAGE_REACTION_REMOVE_ALL d -> !Config.reaction_bulk_remove d
| PRESENCE_UPDATE d -> !Config.presence_update d
| TYPING_START d -> !Config.typing_start d
| USER_UPDATE d -> !Config.user_update d
| VOICE_STATE_UPDATE d -> !Config.voice_state_update d
| VOICE_SERVER_UPDATE d -> !Config.voice_server_update d
| WEBHOOKS_UPDATE d -> !Config.webhooks_update d

let handle_event ~ev contents =
    (* Printf.printf "Dispatching %s\n%!" ev; *)
    (* print_endline (Yojson.Safe.prettify contents); *)
    try
        event_of_yojson ~contents ev
        |> dispatch
    with Invalid_event ev -> Printf.printf "Unknown event: %s%!" ev