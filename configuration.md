# Configuration

RustBB is configured with environment variables. With systemd they come from `/etc/rustbb/env` (the unit's `EnvironmentFile`); with Docker, from `--env-file` or `environment:`. A `.env` file in the working directory is read too, for variables not already set. `env.example` in every archive lists them all.

An empty value counts as unset. Settings are read when the server starts: restart it after a change. [`rustbb check`](command-line.md#checking-the-setup) checks them without starting the server.

| Variable | Default | Meaning |
| --- | --- | --- |
| `RUSTBB_BASE_URL` | `http://` and the listen address | The forum's public address, such as `https://forum.example.com`. Used for links, feeds, the sitemap and link previews, the session cookie (`Secure` when it is `https://`) and the Telegram login. |
| `RUSTBB_SITE_NAME` | `RustBB` | The site name a new forum starts with; then see [Site settings](#site-settings) |
| `RUSTBB_REGISTRATION` | `INVITE` | `OPEN`, `INVITE` or `CLOSED` for a new forum; then see [Site settings](#site-settings) |
| `RUSTBB_TELEGRAM_BOT_TOKEN` | | The bot's token from BotFather |
| `RUSTBB_TELEGRAM_BOT_USERNAME` | | The bot's username, without `@` |
| `RUSTBB_ADMIN_TELEGRAM_ID` | | The numeric Telegram id that can always register and becomes administrator |
| `RUSTBB_OIDC_<NAME>_ISSUER`, `_CLIENT_ID`, `_CLIENT_SECRET`, `_LABEL` | | Sign-in with an OpenID Connect provider such as Google, Keycloak or Authentik; see [Sign-in](sign-in.md#openid-connect) |
| `RUSTBB_GITHUB_CLIENT_ID`, `RUSTBB_GITHUB_CLIENT_SECRET` | | Sign-in with GitHub; see [Sign-in](sign-in.md#github) |
| `RUSTBB_TRUST_PROXY` | `0` | `1` behind a web server such as Xenia, Caddy or Nginx: the last `X-Forwarded-For` entry is then the visitor's address, for rate limits. Leave it `0` when visitors reach RustBB directly, or they could fake their address. |
| `RUSTBB_SESSION_DAYS` | `30` | How long a sign-in lasts |
| `RUSTBB_SHOW_VERSION` | `1` | `0` hides the version in the "Powered by RustBB" footer |
| `RUSTBB_CUSTOM_CSS` | | A stylesheet of your own, such as `/etc/rustbb/custom.css`, added after RustBB's; see [Look](#look) |
| `RUSTBB_LOG` | `info` | Log filter, such as `info` or `info,tower_http=debug` |
| `RUSTBB_LOG_FORMAT` | `text` | `json` writes one JSON object per line, for log collectors; see [Monitoring](monitoring.md#logs) |
| `RUSTBB_METRICS_BIND` | | Address and port for Prometheus metrics, such as `127.0.0.1:9090`; off when unset. See [Monitoring](monitoring.md#metrics) |
| `RUSTBB_BIND` | `127.0.0.1:8080` | Address and port to listen on |
| `RUSTBB_DATABASE_PATH` | `rustbb.db` | The SQLite database; created if missing |
| `RUSTBB_UPLOADS_PATH` | `uploads` next to the database | Where avatars and images attached to posts are stored; created at the first upload. Back it up with the database ([Deployment](deployment.md#backups)) |
| `RUSTBB_UPLOAD_MAX_MB` | `5` | The largest image a member may upload, in megabytes; `0` turns avatars and attachments off |

The systemd unit sets `RUSTBB_BIND` and `RUSTBB_DATABASE_PATH` itself (`127.0.0.1:8080` and `/var/lib/rustbb/rustbb.db`), and so does the image (`0.0.0.0:8080`, same database). Leave them out of the environment file: a value there overrides theirs.

`env.example` ends with `RUSTBB_DEV_LOGIN`, which only development builds read; release builds ignore it.

## Site settings

The site name, a short description, the language, the registration mode, and the forum's colours and logo are set under **Admin → Settings**, and take effect at once. They are kept in the database, with the forum's content.

`RUSTBB_SITE_NAME` and `RUSTBB_REGISTRATION` only give the first values: the first start of a new forum, or of a forum upgraded from 0.3, stores them. After that the database's values count, and the variables are ignored; [`rustbb check`](command-line.md#checking-the-setup) warns when they still differ, so they can be removed.

The description is shown on the front page and to search engines (the pages' meta description).

### Languages

RustBB speaks English and Russian. The forum's language, under **Admin → Settings**, is what visitors see, and what the feeds, the moderation log's details and the bot's messages use for members who have not chosen one. Each member can choose their own under **Settings**, for the pages and the bot's messages to them. The command line, the logs and `rustbb check` stay in English: they are for whoever runs the forum.

Everything a page says comes from `locales/en.toml` and `locales/ru.toml`, built into the binary. Another language is one more such file with the same keys, its plural rules in `src/i18n.rs` and a line in its list of languages; `cargo test` checks that every language has every key and the same placeholders. What members write, and the names of devices in their session list ("Firefox on Linux"), are not translated.

### Look

Under **Admin → Settings**:

- **Accent colour:** links, buttons, panel headings and quotes, written as `#rrggbb` (or `#rgb`). It must have a contrast of at least 4.5:1 with the light page background, as WCAG AA asks of text; RustBB refuses a lighter one and says by how much it falls short. The pale tint behind panel headings and the lighter shade used in dark mode are made from it, keeping the same contrast.
- **Header colour:** the bar at the top of every page. Any colour works: its text turns white or black, whichever reads better.
- **Logo:** an image shown in the header in place of the site name, 40 pixels high, on the header colour; the site name stays its text for screen readers. PNG, JPEG, GIF or WebP, decoded and encoded again like members' images, and stored with them in `RUSTBB_UPLOADS_PATH` (at most 120 pixels high). A transparent PNG works best. Uploading needs uploads on (`RUSTBB_UPLOAD_MAX_MB` above 0).

Empty colour fields keep RustBB's own. For anything else, `RUSTBB_CUSTOM_CSS` names a stylesheet that comes after RustBB's and the colours above, so it can change them too. RustBB's colours are CSS variables at the top of its stylesheet, `/static/style.css` on any forum (`--accent`, `--head`, `--panel` and so on), and redefining them is the simplest way to restyle the forum; mind the dark scheme (`@media (prefers-color-scheme: dark)`) and the contrast. The file is read when the forum starts, so restart it after a change; one that is missing, larger than 512 KB or not UTF-8 text stops the start, and `rustbb check` says so. The pages' Content-Security-Policy lets the stylesheet load images and fonts only from the forum itself or as `data:` URLs.

There are no template overrides: the pages' HTML is RustBB's, so that upgrades never break a forum's look.
