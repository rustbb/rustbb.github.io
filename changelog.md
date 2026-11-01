# Changelog

What changed in each RustBB release, for the people who run a forum. Each
release says whether it migrates the database; a migrating release cannot be
rolled back without the backup taken before the upgrade.

A release tag `vX.Y.Z` needs a `## X.Y.Z` section here.

## 0.6.0

Moving from phpBB, packages for Debian, Ubuntu, Fedora and Enterprise
Linux with their own repositories, a Homebrew tap, an install script, and
a security policy.

Database: migrates, with migration 0019 (claim codes for accounts
imported from phpBB, and which phpBB numbers they and their images had).
The database is backed up first.

Moving from phpBB:

- `rustbb import phpbb DUMP` imports a phpBB 3.2 or 3.3 forum from a
  MySQL or MariaDB dump into a new forum: members with their roles,
  signatures and bans, categories and forums with who may read and post,
  forum moderators, topics and posts (BBCode becomes Markdown), and with
  `--files` attached images and avatars. Forums, topics and posts keep
  their numbers, and phpBB's links (`viewtopic.php`, `viewforum.php`,
  `memberlist.php`, `download/file.php`) redirect to them. Names that are
  not Latin letters are transliterated. `--dry-run` checks everything and
  changes nothing. Passwords, email and IP addresses are not read.
- Imported members claim their accounts with a code from Admin, Users or
  `rustbb user claim`, entered on the registration page after signing in
  with Telegram or another provider, even while registration is closed.
- Moving from phpBB in the docs explains it.

Security:

- Vulnerabilities are reported privately through GitHub's private
  vulnerability reporting on rustbb/releases, whose new security policy
  (`SECURITY.md`) says what happens next. Security in the docs says so,
  and will list the external review's findings and fixes.

Installing:

- Debian and Ubuntu packages (`rustbb_VERSION_amd64.deb`, `_arm64`) and
  rpms for Fedora and EL9/EL10 (`x86_64`, `aarch64`) come with each
  release. They install the binary as `/usr/bin/rustbb`, the systemd
  unit and `/etc/rustbb/env`, and do not start the forum until it is set
  up; an upgrade keeps the settings and restarts a running forum. The
  Debian package suggests `xenia-server`.
- `https://rustbb.github.io/install.sh` installs a release on Linux as a
  systemd service, or the binary alone on macOS or without root, after
  checking the archive against `SHA256SUMS` (and its signature, when
  cosign is installed). Run again, it upgrades.
- APT and dnf repositories, `https://rustbb.github.io/apt` and
  `https://rustbb.github.io/rpm`, signed by RustBB's key
  `8A5C 916C 2231 973F 4D69 F84D 675A 145E BCF4 5CC2`, so `apt upgrade`
  and `dnf upgrade` bring new releases. Deployment, Packages says how to
  add them.
- Homebrew, for trying RustBB out on macOS or Linux:
  `brew install rustbb/tap/rustbb`, then `brew services start rustbb`.
- Deployment in the docs has a Packages section.

## 0.5.0

Community essentials: more ways to sign in, bot notifications, search,
unread tracking, mentions and watched topics, moderation tools, per-forum
permissions, avatars and images, feeds, English and Russian, and the
forum's own look.

Database: migrates, with migrations 0009 to 0018 (sign-in methods move
from the `users` table's Telegram columns to new `identities` and
`passkeys` tables, and `users` is rebuilt; a `notifications` table,
notification settings for members and the topics they watch; search
indexes for topic titles and posts; reading marks per member, forum and
topic, and each topic's last post; forum moderators, reports, post edit
history and the moderation log; who may read and post in each forum;
uploaded images and avatars; each member's language; the forum's logo
among the uploads). The database is backed up first.
After upgrading, everything already on the forum counts as read. If you
pinned `api.telegram.org` to IPv4 in `/etc/hosts` because 0.4.0 could
not reach Telegram, remove that line (see Running a forum below).

Signing in:

- Besides Telegram, members can sign in with OpenID Connect providers
  such as Google, Keycloak or Authentik (`RUSTBB_OIDC_<NAME>_ISSUER`,
  `_CLIENT_ID`, `_CLIENT_SECRET` and an optional `_LABEL`), with GitHub
  (`RUSTBB_GITHUB_CLIENT_ID` and `_CLIENT_SECRET`), and with passkeys. A
  forum without Telegram is possible. Sign-in in the docs explains the
  setup for each provider.
- One account can have several ways to sign in: Settings, Sign-in lists
  them, adds Telegram, the providers you set up and passkeys, and removes
  any but the last. Passkeys need the forum on https:// (or localhost) and
  are added after signing in another way.
- `rustbb check` shows the redirect address to register with each
  provider, and asks each OpenID Connect provider whether it answers.
- Invitation codes work for every way of signing in; invitations for a
  Telegram username and invitation requests stay with Telegram accounts.
  Open registration now reads "anyone who can sign in".
- `rustbb user list` and Admin, Users show how each member signs in,
  instead of a Telegram id. A member's data download lists the accounts
  and passkeys they sign in with, under `sign_in_accounts` and `passkeys`
  instead of `telegram`.

Notifications:

- Members who sign in with Telegram get a bot message when someone
  replies to their topics, with the title and a link. Replies that come
  before the message is sent join it. Members turn them off under
  Settings, Notifications.
- Mentions: `@username` in a post links to that member's profile, and
  the bot tells them (at most ten people per post; not in code or
  links).
- Watched topics: the Watch button at the top of a topic, and Settings,
  Watched topics to list and stop them; the bot tells watchers about new
  replies. Members can choose to watch every topic they reply to.
- Each kind (replies, mentions, watched topics) can be turned off under
  Settings, Notifications; someone who is several at once gets one
  message.
- Sending happens in the background and is tried again when Telegram
  cannot be reached; members who blocked the bot are not tried again. New
  metrics: `rustbb_notifications_total` and
  `rustbb_notifications_waiting`. The data download includes them.

Finding things:

- Search: a search box in the header, and a Search page that can keep to
  one forum. It finds topic titles and posts in which every word appears,
  as a word or the start of one ("migrat" finds "migration"), and "words
  in quotes" together; accents do not matter ("cafe" finds "café"), and
  any script works. Matching titles come first, then posts, with the
  words marked. A search for a very common word ranks the newest 1,000
  matches. Built on SQLite's FTS5: on the reference forum of 50,000 posts
  the index is a quarter of the database, and the upgrade builds it in
  under a second.
- Unread tracking: the front page says which forums have new posts, a
  forum's page marks topics with new posts, and "New" there leads to the
  first post not yet read; in a topic, posts not seen before are marked
  New. "Mark forum read" and, on the front page, "Mark all read" clear
  them. Members' own posts are never new to them, and new members start
  with everything read. The data download includes what a member has
  read.
- Feeds and search engines: Atom and RSS feeds of the newest topics in
  the forum (`/feed.atom`, `/feed.rss`) and in each forum, and of the
  newest posts in each topic, which pages link to; a sitemap
  (`/sitemap.xml`) and `robots.txt`. Pages name their canonical address
  and carry OpenGraph tags, so shared links show a title, a description
  and the first image. All of it is what visitors may read: forums for
  members or staff are left out. See Deployment, Feeds and search engines.
  The pages' meta description is now the topic's first post or the
  forum's description where there is one.

Moderation:

- Moderators for some forums only: under Admin, Categories & forums,
  each forum takes a list of moderator usernames. They moderate those
  forums (lock, pin, move between their forums, edit and delete posts,
  delete topics, reports) and are members elsewhere.
- Who may read and post, for each forum (Admin, Categories & forums):
  reading for everyone, signed-in members or staff only; posting for
  members, staff starting topics with members replying (announcements),
  or staff only (read-only). A staff-only forum is hidden from everyone
  else everywhere: the front page, its pages, search, profiles and
  notifications.
- Reports: members report someone else's post with a reason. Moderators
  of the forum see "Reports (N)" in the header and the queue, dismiss a
  report or delete the post, and get a bot message about each new report
  unless they turn that off under Settings, Notifications.
- Edit history: an edited post keeps its earlier versions, which its
  author and the forum's moderators can open.
- A moderation log of locks, pins, moves, deletions, edits of others'
  posts, dismissed reports, role and forum moderator changes, and bans.
  Moderators see it all; forum moderators see their forums'.
- See Moderation in the docs. The data download includes reports a
  member made; erasing a member's posts erases their earlier versions.

Avatars and images:

- Members choose an avatar under Settings (cut to a square, 256 pixels),
  shown with their posts and on their profile.
- Posts can carry up to four images (PNG, JPEG, GIF or WebP), added when
  writing or editing and shown under the post. Every image is decoded
  and encoded again, so the original file's EXIF (where a photo was
  taken, the camera's serial number) and anything else in it are gone;
  photos are turned upright first, and images larger than 2,560 pixels
  are scaled down. A GIF keeps its first frame.
- Images are served only to those who may read the post. They are kept
  in `RUSTBB_UPLOADS_PATH` (by default `uploads` next to the database);
  back that directory up with the database. `RUSTBB_UPLOAD_MAX_MB` (5 by
  default) limits their size; 0 turns uploads off. `rustbb check` checks
  the directory. The static Linux binary is about 1.2 MB larger (the
  `image` crate), about 12 MB in all; its notices list the new libraries.

Languages:

- RustBB speaks English and Russian. The forum's language is set under
  Admin, Settings, and is what visitors, feeds and members who chose none
  see; each member can choose their own under Settings, for the pages and
  the bot's messages to them. Plurals follow each language's rules ("21
  ответ", "3 ответа", "5 ответов"). Every string a page shows lives in
  `locales/en.toml` and `locales/ru.toml`; tests check that both have the
  same keys and placeholders, and that every key used exists. The command
  line, logs and `rustbb check` stay in English. See Configuration,
  Languages. The data download includes a member's language.

Look:

- Admin, Settings sets an accent colour (links, buttons, panel headings)
  and a header colour. An accent too light to read on the page's
  background (less than 4.5:1) is refused; the tint behind headings and
  the lighter shade for dark mode are made from it with the same
  contrast, and the header's text turns white or black to suit.
- A logo, uploaded there too, takes the site name's place in the header.
- `RUSTBB_CUSTOM_CSS` adds a stylesheet of your own after RustBB's; it is
  read at startup, and `rustbb check` shows it. See Configuration, Look.
  There are no template overrides.

Running a forum:

- The bot reaches Telegram from servers whose IPv6 route to
  `api.telegram.org` is broken. Outgoing connections (the bot, OpenID
  Connect providers and GitHub) now try a host's IPv6 and IPv4 addresses
  side by side, as browsers do, instead of spending most of the time
  limit on the first one: 0.4.0 timed out there (`rustbb check`:
  "timeout: global") and could not send bot messages. A line in
  `/etc/hosts` that pins `api.telegram.org` to IPv4 is no longer needed.
  When no address answers, the error names each one, IPv6 or IPv4, and
  what happened.
- The performance budget's load test now also searches and signs in to
  the front page.
- Stability, a new page in the docs, says what stays the same across
  1.x from 1.0 on: the settings, the commands and their options, upgrades
  from any release since 0.2.0, the public addresses (forums, topics,
  posts, profiles, feeds, the sitemap and the sign-in callbacks), the
  metrics, and the class names and colour variables a custom stylesheet
  can use. Deprecated settings and commands keep working until 2.0, and
  fixes go into the newest 1.x release. `cargo test` fails when a release
  would drop any of them.
- Command line in the docs lists every command and option.
- `env.example` now shows the OpenID Connect, GitHub and upload settings
  too.

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
