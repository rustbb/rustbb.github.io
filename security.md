# Security

What RustBB does to protect a forum and its members, and what is left to the operator.

## Accounts and sessions

- There are no passwords to leak. Members sign in with Telegram, whose signature RustBB checks on every login ([Telegram](telegram.md#how-sign-in-is-checked)), with an OpenID Connect provider or GitHub through the authorization code flow with PKCE, or with passkeys: see [Sign-in](sign-in.md#how-sign-in-is-checked).
- Sessions are rows in the database. The cookie holds only a random token and is `HttpOnly`, `SameSite=Lax`, and `Secure` when `RUSTBB_BASE_URL` is `https://`. Banning a user ends their sessions. Members see where they are signed in under **Settings → Sessions**, and end any of those sessions, or all but the current one.
- Administrators ban members for a time or for good, with a reason the member is shown, and ban addresses or ranges of addresses: nobody from those can use the forum (Admin → Bans, or [`rustbb user ban` and `rustbb ip ban`](command-line.md)). Bans never apply to the server's own address, where a web server in front connects from, and an administrator cannot ban the address they use.
- Logins, registrations and posting are rate limited per visitor. Behind a web server, set `RUSTBB_TRUST_PROXY=1` so the limits see visitors' addresses (see [Configuration](configuration.md)).

## Requests and pages

- Cross-site request forgery is blocked by `SameSite=Lax` cookies and a check of the `Sec-Fetch-Site` header (or `Origin`) on every request that changes something.
- Templates escape everything by default. Posts are Markdown, sanitized with [ammonia](https://github.com/rust-ammonia/ammonia); images are removed.
- A strict Content-Security-Policy allows scripts and styles only from the forum itself, plus `telegram.org` for the login widget, and no other site may show the forum in a frame.

## Data

- [Privacy](privacy.md) lists everything RustBB stores about members, and how they download it or delete their account.
- The request log records paths only, never query strings, so login data and codes never reach log files.
- RustBB sends nothing about the forum or its members to its author. It talks to `api.telegram.org` only to send the bot messages described in [Telegram](telegram.md#requests), and to the OpenID Connect providers and GitHub you set up, only while someone signs in.

## The operator's part

- Serve the forum over HTTPS, with a web server in front: [Deployment](deployment.md#a-web-server-in-front).
- Keep the database file private (the systemd unit and the image do), and back it up: it holds every account and post.
- Upgrade when a release fixes a security issue: the [changelog](changelog.md) says so.
