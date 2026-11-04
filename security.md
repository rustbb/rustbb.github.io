# Security

What RustBB does to protect a forum and its members, and what is left to the operator.

## Accounts and sessions

- There are no passwords to leak. Members sign in with Telegram, whose signature RustBB checks on every login ([Telegram](telegram.md#how-sign-in-is-checked)), with an OpenID Connect provider or GitHub through the authorization code flow with PKCE, or with passkeys: see [Sign-in](sign-in.md#how-sign-in-is-checked).
- Sessions are rows in the database. The cookie holds only a random token and is `HttpOnly`, `SameSite=Lax`, and `Secure` when `RUSTBB_BASE_URL` is `https://`. Banning a user ends their sessions. Members see where they are signed in under **Settings → Sessions**, and end any of those sessions, or all but the current one.
- Administrators ban members for a time or for good, with a reason the member is shown, and ban addresses or ranges of addresses: nobody from those can use the forum (Admin → Bans, or [`rustbb user ban` and `rustbb ip ban`](command-line.md)). Bans never apply to the server's own address, where a web server in front connects from, and an administrator cannot ban the address they use.
- Logins, registrations and posting are rate limited per visitor: per address for IPv4, and per /64 for IPv6, which one subscriber usually has whole. Banning a member's last address bans its /64 the same way. Behind a web server, set `RUSTBB_TRUST_PROXY=1` so the limits see visitors' addresses (see [Configuration](configuration.md)).

## Requests and pages

- Cross-site request forgery is blocked by `SameSite=Lax` cookies and a check of the `Sec-Fetch-Site` header (or `Origin`) on every request that changes something.
- Templates escape everything by default. Posts are Markdown, sanitized with [ammonia](https://github.com/rust-ammonia/ammonia); images are removed.
- Uploaded images are decoded within limits on their size and the memory they take, and encoded again, so only their pixels are kept.
- A strict Content-Security-Policy allows scripts and styles only from the forum itself, plus `telegram.org` for the login widget, and no other site may show the forum in a frame.

## Data

- [Privacy](privacy.md) lists everything RustBB stores about members, and how they download it or delete their account.
- The request log records paths only, never query strings, so login data and codes never reach log files.
- RustBB sends nothing about the forum or its members to its author. It talks to `api.telegram.org` only to send the bot messages described in [Telegram](telegram.md#requests), and to the OpenID Connect providers and GitHub you set up, only while someone signs in.

## Reporting a vulnerability

Report it privately, never in a public issue: on the [rustbb/releases](https://github.com/rustbb/releases) repository's **Security** tab, choose **Report a vulnerability**. Its [security policy](https://github.com/rustbb/releases/blob/main/SECURITY.md) says what to include, how soon you hear back, and how fixes are released. A release that fixes a vulnerability says so in the [changelog](changelog.md).

## Reviews

Before 1.0, an external reviewer examines sign-in, sessions, permissions, sanitization, uploads, the admin area and the phpBB importer. When the review is done, this section names who reviewed which version, and what they found and in which release it was fixed.

Ahead of it, RustBB's developers reviewed 0.7.0's sign-in, sessions, permissions, sanitization, requests and uploads themselves, and fuzzed its parsers, in November 2026. What they found is fixed in 0.7.1:

| Severity | Found | Fixed |
| --- | --- | --- |
| Medium | A copy of a Telegram login address, from a shared computer's history say, could be used again within fifteen minutes: to register that Telegram account as one's own, or, once its owner had registered, to sign in as them. | Each Telegram login works once, whatever it leads to, and only in the browser the forum showed the widget to; a second registration form for an account registered meanwhile signs nobody in. |
| Medium | A few bytes of image could ask for a canvas of 12,000 by 12,000 pixels, which took about a gigabyte of memory to decode, enough to stop a forum on a small server. | The memory an image needs is checked before it is decoded, against a lower limit. |
| Low | Another site could start adding an account at a provider to a signed-in member's, without asking them. | Adding one at once takes the button in Settings; any other way asks first. |
| Low | Any site could sign a visitor into its own account by sending them to a Telegram login made elsewhere. | As for the first one. |
| Low | Visitors with IPv6 could change addresses within their network to get round rate limits and address bans. | Limits and bans of a member's last address count the /64. |
| Low | A busy forum's rate limiter could forget the hourly limits early. | Each limit keeps its own hours. |
| Low | The moderation log could show forum moderators the name of a staff-only forum a topic was moved from, and a member's data the name of one their topic was moved into. | Neither names a forum the reader may not read. |
| Low | A moderator who had lost the role could still get the bot's message about a report queued before. | Messages about reports go only to those who still moderate. |
| Low | A poll's author could change or delete it in a locked topic, and delete their topic together with others' votes in its poll. | Neither, as for their posts. |
| Info | A copied passkey used at the same moment as the original could pass the use-count check; a Telegram field with a line break in it could pass for others; only the first `X-Forwarded-For` line was read. | Fixed. |

## The operator's part

- Serve the forum over HTTPS, with a web server in front: [Deployment](deployment.md#a-web-server-in-front).
- Keep the database file private (the systemd unit and the image do), and back it up: it holds every account and post.
- Upgrade when a release fixes a security issue: the [changelog](changelog.md) says so.
