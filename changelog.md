# Changelog

What changed in each RustBB release, for the people who run a forum. Each
release says whether it migrates the database; a migrating release cannot be
rolled back without the backup taken before the upgrade.

A release tag `vX.Y.Z` needs a `## X.Y.Z` section here.

## 0.4.0

Settings in the browser, bans with reasons and address bans, members'
sessions and data, monitoring, accessibility, and a performance budget.

Database: migrates (a new `settings` table, `deleted_at` and ban details
for users, the device, address and last use of sessions, and a new
`ip_bans` table), and adds indexes for counting posts. The database is
backed up first, as since 0.3.0. After upgrading, the site name and the
registration mode are set under Admin, Settings: the first start stores
your `RUSTBB_SITE_NAME` and `RUSTBB_REGISTRATION`, and later changes to
them are ignored (`rustbb check` says when they differ).

Running a forum:

- `rustbb check` checks the settings, the database and the Telegram bot,
  and explains each problem: an address that is not https or has a path,
  a bot token or username that cannot be right, `RUSTBB_TRUST_PROXY` that
  does not match where RustBB listens, a forum with no way to get an
  administrator, pending migrations, a database from a newer version, and
  whether Telegram accepts the token. It changes nothing, and exits with
  status 1 if anything fails. `--offline` skips asking Telegram.
- The site name, a new site description and the registration mode are set
  under Admin, Settings, and take effect at once. They are stored in the
  database. `RUSTBB_SITE_NAME` and `RUSTBB_REGISTRATION` now only give a
  forum its first values: the first start of this version stores the ones
  you have, and after that the variables are ignored (`rustbb check` warns
  while they differ). The description is shown on the front page and as
  the pages' meta description.
- Monitoring. `RUSTBB_LOG_FORMAT=json` writes logs as one JSON object per
  line, for log collectors. `RUSTBB_METRICS_BIND` (such as
  `127.0.0.1:9090`) serves Prometheus metrics on an address of its own:
  requests and their times per route, crashes, memory, the database size,
  and the number of users, topics, posts and sign-ins. `rustbb check` warns
  when that address is not a loopback one. A crash while answering a
  request is now logged with the version and the place in the source, and
  the visitor gets an error page instead of a closed connection. See the
  new Monitoring page in the docs.
- Faster front page on large forums: counting each forum's posts no longer
  reads every post (new indexes; on 50,000 posts, 23 ms to 8 ms a view).
  A performance budget now holds every change to 50 ms p95 page time and
  50 MB of memory at 100 requests a second on one CPU; Deployment in the
  docs says what a forum needs.

Bans:

- Bans have a reason and may end by themselves: Ban on Admin, Users now
  opens a form with the reason, how long (a day to a year, or for good),
  and whether to ban the address the member last used too. A banned
  member who tries to sign in is told why and until when; when the ban
  ends they can sign in again. `rustbb user ban <name> --reason ... --days
  N` does the same.
- Address bans: Admin, Bans lists banned members and addresses, and bans
  an address or a range such as `203.0.113.0/24` (up to /16, or /32 for
  IPv6), for a time or for good. Nobody from a banned address can use the
  forum. The server's own address, where a web server in front connects
  from, and the banning administrator's address cannot be banned. On the
  command line: `rustbb ip list|ban|unban`; a running server applies
  those within a minute.
- Sessions now keep the address they started from, shown to the member on
  their Sessions page, so that administrators can ban it.

Members:

- Settings, Sessions shows members where they are signed in: the browser
  and system ("Firefox on Linux"), when each session started, was last
  active and expires. They can end any other session, or all of them but
  the current one. Sessions from before this version show as "Unknown
  device". Expired sessions are now removed when the member signs in
  again.
- Members can download their data and delete their account, under
  Settings. The download is a JSON file with their account, Telegram id
  and username, sign-ins, topics and posts. Deleting signs them out and
  removes everything that identifies them; their posts stay, shown as by
  a deleted account, unless they choose to erase them too (topics only
  they wrote in are then removed). The only administrator cannot delete
  their account. Operators do the same with `rustbb user export <name>`
  and `rustbb user delete <name> [--erase-posts]`. SQLite now overwrites
  deleted data in the database file. The new Privacy page in the docs
  lists what RustBB stores, for writing a forum's privacy notice.
- Accessibility. Every page has a "Skip to content" link, one main
  heading, and labelled navigation (account, breadcrumb, pages) that says
  where you are. Whatever has keyboard focus gets a clear outline. Every
  form field has a label, and repeated buttons such as Quote, Edit,
  Delete and Save say what they act on. In the dark scheme, buttons,
  "banned" and "locked" tags and error messages now have enough contrast;
  form field borders and links within text are easier to see; small
  buttons are at least 24 pixels high. Unknown addresses now get the
  "Not found" page instead of an empty answer.

For the people who build RustBB:

- Wider tests: every route is tried by a visitor, a member, a moderator,
  an administrator and a banned member, and a real browser signs in,
  posts and signs out in CI. Nothing changes for a running forum.

## 0.3.0

Invitations without codes, automatic backups before upgrades, and
documentation at https://rustbb.github.io.

Database: migrates (invitations for a Telegram username or account, and a
new `join_requests` table). 0.3.0 backs the database up first, next to it;
see "Upgrading" in the docs for going back. Before upgrading, check your
environment file (the `env.example` item below).

Invitations:

- The administrator named in `RUSTBB_ADMIN_TELEGRAM_ID` can register
  without an invitation code, even when registration is `INVITE` or
  `CLOSED`. In 0.2.0 a new forum's first account needed a code made with
  `rustbb invite create` on the server.
- An invitation can be for a Telegram username: "For Telegram user" on
  the Invitations page, or `rustbb invite create --for alice`. When that
  account registers, the invitation applies by itself and there is no code
  to type; nobody else can use its code. Such an invitation allows one
  registration.
- People without a code can ask for an invitation from the registration
  form, with an optional note. The bot messages the administrator about
  each request, once per Telegram account. Approve or decline on Admin,
  Requests, or with `rustbb request list`, `approve <id>` and
  `decline <id>`. Approving creates an invitation for that Telegram account
  and the bot tells them to log in; there is no code to type. A declined
  account cannot ask again.
- RustBB now sends bot messages, so the server must reach
  `api.telegram.org` over HTTPS. The binary is about 1.7 MB larger (rustls
  with Mozilla's root certificates built in), and its notices now include
  the ISC and CDLA-Permissive-2.0 licenses.

Upgrades:

- Before applying migrations, RustBB backs up the database next to it, as
  `rustbb-before-VERSION-TIME.db`, and does not migrate if the copy cannot
  be written. Remove old copies when you no longer need them.
- `rustbb migrate --dry-run` lists the migrations a new version would
  apply, without changing anything.
- `rustbb backup` copies the database as it is. Before, a newer binary
  migrated the database first.
- RustBB refuses a database that a newer version migrated, with a message
  saying so.

Documentation and setup:

- The documentation is at https://rustbb.github.io: getting started,
  Telegram and invitations, configuration, deployment, Docker, the command
  line, upgrading and security. "Powered by RustBB" in the footer links
  there.
- `env.example` no longer sets `RUSTBB_BIND` and `RUSTBB_DATABASE_PATH`.
  Copied as the systemd environment file, its values overrode the unit's,
  so the service looked for its database in `/` and could not start; given
  to the image with `--env-file`, the forum listened only inside the
  container. If your environment file has these two lines from 0.2.0's
  `env.example`, remove them.

## 0.2.0

The first public release. RustBB is a classic forum (categories, forums,
topics and posts) in one executable with SQLite built in: sign-in through
Telegram with no passwords or email, user, moderator and administrator
roles, open, invitation-only or closed registration, Markdown posts,
moderation, rate limits and bans, administration pages and a command line.
Archives for Linux (static, x86_64 and arm64), macOS (arm64 and x86_64) and
Windows (x86_64), and an image for amd64 and arm64.

Database: a new forum's database is created on first start; no migration
from the 0.1.0 proof of concept.

Since the proof of concept:

- RustBB is distributed under the RustBB License (`LICENSE` in every
  archive, `/licenses` in the image): free to use for any purpose,
  including hosting forums for others, closed source.
- Releases are signed with cosign: `SHA256SUMS` and the image can be
  verified as the README describes. The image is `ofkindness/rustbb`, for
  amd64 and arm64.
- `rustbb --version` prints the version, the commit it was built from and
  the build date, and the server logs the same line when it starts.
- The footer shows the running version, for example "Powered by RustBB
  0.2.0". `RUSTBB_SHOW_VERSION=0` hides it.
- `rustbb licenses` prints the licenses of the open-source components built
  into the binary; every archive has them as `THIRD-PARTY-LICENSES` too.
- The static Linux binaries use the mimalloc allocator, which holds up
  better than musl's under concurrent load.
