# Changelog

What changed in each RustBB release, for the people who run a forum. Each
release says whether it migrates the database; a migrating release cannot be
rolled back without the backup taken before the upgrade.

A release tag `vX.Y.Z` needs a `## X.Y.Z` section here.

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
