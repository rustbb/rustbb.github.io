# Telegram

Members can sign in with the [Telegram Login Widget](https://core.telegram.org/widgets/login). RustBB keeps no passwords and asks Telegram for no email address: the forum knows a member's Telegram id, and the forum username they chose at registration, independent of the Telegram username. Telegram is one of the ways to sign in; [Sign-in](sign-in.md) has the others.

## The bot

The login widget belongs to a bot. Create one with [@BotFather](https://t.me/BotFather) (`/newbot`), then send BotFather `/setdomain` with the forum's public domain: the widget works only there. Set:

```sh
RUSTBB_TELEGRAM_BOT_TOKEN=123456:ABC...
RUSTBB_TELEGRAM_BOT_USERNAME=example_forum_bot    # without the @
RUSTBB_BASE_URL=https://forum.example.com
```

The bot also sends [notifications](#notifications) and messages about invitation requests (below). For that the server must reach `api.telegram.org` over HTTPS, and a bot can only write to people who allowed it at login; the login widget asks them.

RustBB tries Telegram's IPv6 and IPv4 addresses side by side and uses whichever answers first, so a server whose IPv6 route to Telegram is broken still gets through over IPv4. No `/etc/hosts` entry or IPv4 preference is needed (the static Linux binary ignores `/etc/gai.conf` anyway). If [`rustbb check`](command-line.md#checking-the-setup) still cannot reach the Bot API, its warning lists each address it tried and what happened.

## The first administrator

Put your own numeric Telegram id in `RUSTBB_ADMIN_TELEGRAM_ID`. That account can always register, without an invitation and even when registration is closed, and it becomes administrator the first time it signs in. A new forum's first account needs no command line.

Without this setting, create the first invitation on the server with `rustbb invite create`, register with it, and make yourself administrator with `rustbb user role <name> admin` (see [Command line](command-line.md)).

## Registration

The registration mode, set under **Admin → Settings**, decides who can join (`RUSTBB_REGISTRATION` gives a new forum its first mode; see [Configuration](configuration.md#site-settings)). People who already have an account can always sign in.

| Mode | Who can register |
| --- | --- |
| `OPEN` | Anyone who can sign in |
| `INVITE` (the default) | People with an invitation code, or with an invitation for their Telegram account |
| `CLOSED` | Nobody, except the administrator in `RUSTBB_ADMIN_TELEGRAM_ID` |

## Invitations

In `INVITE` mode, create invitations under **Admin → Invitations** or with `rustbb invite create`. Codes work with every way of signing in; invitations for a username are for Telegram accounts:

- **A code** to pass on, for a number of registrations and a number of days (`--uses 5 --days 7`). Days `0` means it never expires.
- **For a Telegram username** ("For Telegram user", or `--for alice`): when that account registers, the invitation applies by itself and there is no code to type. Nobody else can use its code, and it allows one registration.

## Requests

People who sign in with Telegram and have no code can ask for an invitation on the registration page, with an optional note. (Those who sign in another way need a code: the bot could not tell them about the approval.) The bot messages the administrator about each request, once per Telegram account.

Answer under **Admin → Requests**, or with `rustbb request list`, `rustbb request approve <id>` and `rustbb request decline <id>`. Approving creates an invitation for that Telegram account, and the bot tells them to log in again; there is no code to type. The Requests page says when the bot could not reach them. A declined account cannot ask again.

On the command line, `approve` sends the message itself, so it needs the server's bot settings as well as its database: run it as [Command line](command-line.md#on-a-server-with-systemd) shows.

## Notifications

The bot messages members, with the topic's title and a link to the post:

- when someone replies to their topics;
- when someone mentions them, as `@username` in a post (in text, not in code or a link; at most ten people per post);
- when someone replies in a topic they watch;
- for moderators, when someone reports a post in a forum they moderate (see [Moderation](moderation.md#reports)). The **Watch** button at the top of a topic starts that, and **Settings → Watched topics** lists them. Members can also choose to watch every topic they reply to.

Members turn each kind off under **Settings → Notifications**; all three are on at first, and watching the topics one replies to is off. Someone who is several of these at once (mentioned in a reply to their own topic, say) gets one message. Only members who sign in with Telegram get messages, and only from a forum with a bot; without a bot the Watch button is not shown.

Writing a reply only queues the message; a task in the server sends it, a moment later, so nobody waits for Telegram. Replies that come before a member's message is sent join it ("3 new replies to your topic …"), so a busy topic does not send one message per reply. When Telegram cannot be reached, the server tries again after a minute, five minutes, half an hour and two hours, then gives up. A member who blocked the bot, or never let it write to them, is not tried again; the login widget asks for that permission, and opening the bot in Telegram and pressing **Start** gives it too.

The log says when a message could not be sent, and the [metrics](monitoring.md#metrics) count sent and failed ones. Sent and given-up messages are removed from the database after 30 days.

## How sign-in is checked

Telegram does not offer OpenID Connect. The widget sends a payload signed by Telegram, and RustBB checks it directly: an HMAC-SHA256 keyed with the SHA-256 of the bot token. It rejects payloads older than fifteen minutes and accepts each payload only once. The request log never records query strings, so login payloads stay out of log files.
