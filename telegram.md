# Telegram

Members sign in with the [Telegram Login Widget](https://core.telegram.org/widgets/login). RustBB keeps no passwords and asks for no email address: an account is a Telegram id, with a forum username chosen at registration and independent of the Telegram username.

## The bot

The login widget belongs to a bot. Create one with [@BotFather](https://t.me/BotFather) (`/newbot`), then send BotFather `/setdomain` with the forum's public domain: the widget works only there. Set:

```sh
RUSTBB_TELEGRAM_BOT_TOKEN=123456:ABC...
RUSTBB_TELEGRAM_BOT_USERNAME=example_forum_bot    # without the @
RUSTBB_BASE_URL=https://forum.example.com
```

The bot also sends messages about invitation requests (below). For that the server must reach `api.telegram.org` over HTTPS, and a bot can only write to people who allowed it at login; the login widget asks them.

## The first administrator

Put your own numeric Telegram id in `RUSTBB_ADMIN_TELEGRAM_ID`. That account can always register, without an invitation and even when registration is closed, and it becomes administrator the first time it signs in. A new forum's first account needs no command line.

Without this setting, create the first invitation on the server with `rustbb invite create`, register with it, and make yourself administrator with `rustbb user role <name> admin` (see [Command line](command-line.md)).

## Registration

The registration mode, set under **Admin → Settings**, decides who can join (`RUSTBB_REGISTRATION` gives a new forum its first mode; see [Configuration](configuration.md#site-settings)). People who already have an account can always sign in.

| Mode | Who can register |
| --- | --- |
| `OPEN` | Anyone with a Telegram account |
| `INVITE` (the default) | People with an invitation code, or with an invitation for their Telegram account |
| `CLOSED` | Nobody, except the administrator in `RUSTBB_ADMIN_TELEGRAM_ID` |

## Invitations

In `INVITE` mode, create invitations under **Admin → Invitations** or with `rustbb invite create`:

- **A code** to pass on, for a number of registrations and a number of days (`--uses 5 --days 7`). Days `0` means it never expires.
- **For a Telegram username** ("For Telegram user", or `--for alice`): when that account registers, the invitation applies by itself and there is no code to type. Nobody else can use its code, and it allows one registration.

## Requests

People without a code can ask for an invitation on the registration page, with an optional note. The bot messages the administrator about each request, once per Telegram account.

Answer under **Admin → Requests**, or with `rustbb request list`, `rustbb request approve <id>` and `rustbb request decline <id>`. Approving creates an invitation for that Telegram account, and the bot tells them to log in again; there is no code to type. The Requests page says when the bot could not reach them. A declined account cannot ask again.

On the command line, `approve` sends the message itself, so it needs the server's bot settings as well as its database: run it as [Command line](command-line.md#on-a-server-with-systemd) shows.

## How sign-in is checked

Telegram does not offer OpenID Connect. The widget sends a payload signed by Telegram, and RustBB checks it directly: an HMAC-SHA256 keyed with the SHA-256 of the bot token. It rejects payloads older than fifteen minutes and accepts each payload only once. The request log never records query strings, so login payloads stay out of log files.
