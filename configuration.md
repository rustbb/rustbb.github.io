# Configuration

RustBB is configured with environment variables. With systemd they come from `/etc/rustbb/env` (the unit's `EnvironmentFile`); with Docker, from `--env-file` or `environment:`. A `.env` file in the working directory is read too, for variables not already set. `env.example` in every archive lists them all.

An empty value counts as unset. Settings are read when the server starts: restart it after a change.

| Variable | Default | Meaning |
| --- | --- | --- |
| `RUSTBB_BASE_URL` | `http://` and the listen address | The forum's public address, such as `https://forum.example.com`. Used for links, the session cookie (`Secure` when it is `https://`) and the Telegram login. |
| `RUSTBB_SITE_NAME` | `RustBB` | The name in the header and page titles |
| `RUSTBB_REGISTRATION` | `INVITE` | `OPEN`, `INVITE` or `CLOSED`: see [Telegram](telegram.md#registration) |
| `RUSTBB_TELEGRAM_BOT_TOKEN` | | The bot's token from BotFather |
| `RUSTBB_TELEGRAM_BOT_USERNAME` | | The bot's username, without `@` |
| `RUSTBB_ADMIN_TELEGRAM_ID` | | The numeric Telegram id that can always register and becomes administrator |
| `RUSTBB_TRUST_PROXY` | `0` | `1` behind a web server such as Xenia, Caddy or Nginx: the last `X-Forwarded-For` entry is then the visitor's address, for rate limits. Leave it `0` when visitors reach RustBB directly, or they could fake their address. |
| `RUSTBB_SESSION_DAYS` | `30` | How long a sign-in lasts |
| `RUSTBB_SHOW_VERSION` | `1` | `0` hides the version in the "Powered by RustBB" footer |
| `RUSTBB_LOG` | `info` | Log filter, such as `info` or `info,tower_http=debug` |
| `RUSTBB_BIND` | `127.0.0.1:8080` | Address and port to listen on |
| `RUSTBB_DATABASE_PATH` | `rustbb.db` | The SQLite database; created if missing |

The systemd unit sets `RUSTBB_BIND` and `RUSTBB_DATABASE_PATH` itself (`127.0.0.1:8080` and `/var/lib/rustbb/rustbb.db`), and so does the image (`0.0.0.0:8080`, same database). Leave them out of the environment file: a value there overrides theirs.

`env.example` ends with `RUSTBB_DEV_LOGIN`, which only development builds read; release builds ignore it.
