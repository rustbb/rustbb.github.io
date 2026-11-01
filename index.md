# RustBB

A classic bulletin board in one executable, with SQLite built in. Version 0.6.0.

- **Categories, forums, topics and posts**, with Markdown that is sanitized on output, search across them, and what is new since a member last looked.
- **Easy to follow and to find:** Atom and RSS feeds for the forum, each forum and each topic, a sitemap, canonical addresses, and link previews in chats and social networks.
- **Your forum's look:** a logo, accent and header colours that keep their contrast, and a stylesheet of your own.
- **In English and Russian:** the forum chooses its language, and each member their own; more languages are one file each.
- **Sign-in without passwords:** Telegram, OpenID Connect (Google, Keycloak, Authentik), GitHub and passkeys, several for one account.
- **Notifications through the forum's Telegram bot** about replies, `@mentions` and watched topics.
- **User, moderator and administrator roles;** registration that is open, by invitation or closed, and people can ask for an invitation from the forum.
- **Accessible:** usable with a keyboard and a screen reader, with WCAG AA contrast in the light and dark schemes.
- **Moderation:** edit, delete, lock, pin and move; moderators for some forums only; members-only, staff-only, announcement and read-only forums; a report queue, edit history and a moderation log; rate limits and bans; administration pages and a command line.
- **Small:** a static binary of about 12 MB that idles in a few tens of megabytes of memory, on a small VPS behind [Xenia](https://xenia-platform.github.io), Caddy or Nginx.

New to RustBB? [Getting started](getting-started.md) goes from an empty server to a forum over HTTPS.

## Installing

Archives for Linux (static, x86_64 and arm64), macOS and Windows are in [the releases](https://github.com/rustbb/releases/releases), signed with cosign. On a Linux server with systemd, see [Getting started](getting-started.md) or [Deployment](deployment.md).

The [Docker image](docker.md), for amd64 and arm64:

```sh
docker run -d -p 8080:8080 -v rustbb:/var/lib/rustbb --env-file env ofkindness/rustbb:0.6.0
```

## Documentation

- [Getting started](getting-started.md): a forum on a fresh server, step by step.
- [Sign-in](sign-in.md): Telegram, OpenID Connect, GitHub and passkeys.
- [Telegram](telegram.md): the bot, the first administrator, invitations and requests.
- [Configuration](configuration.md): every setting.
- [Deployment](deployment.md): systemd, a web server in front, backups.
- [Docker](docker.md): the image, a Compose file and the command line in a container.
- [Command line](command-line.md): users, invitations, requests and backups.
- [Monitoring](monitoring.md): logs, Prometheus metrics and crashes.
- [Upgrading](upgrading.md): backups, migrations and checking a download.
- [Moving from phpBB](importing.md): importing a phpBB forum, its members and their posts.
- [Stability](stability.md): what stays the same across 1.x, and how deprecations and fixes work.
- [Moderation](moderation.md): moderators, who may read and post in each forum, reports, edit history and the moderation log.
- [Privacy](privacy.md): what RustBB stores, data exports and deleting accounts.
- [Security](security.md): what RustBB does to keep a forum and its members safe.
- [Changelog](changelog.md): what changed in each release.

## License

RustBB is free to use for any purpose, including hosting forums for others, under the [RustBB License](https://github.com/rustbb/releases/blob/main/LICENSE). It is closed source; the releases and these docs are public.
