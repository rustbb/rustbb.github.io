# RustBB

A classic bulletin board in one executable, with SQLite built in. Version 0.4.0.

- **Categories, forums, topics and posts**, with Markdown that is sanitized on output.
- **Sign-in through Telegram:** no passwords and no email anywhere.
- **User, moderator and administrator roles;** registration that is open, by invitation or closed, and people can ask for an invitation from the forum.
- **Accessible:** usable with a keyboard and a screen reader, with WCAG AA contrast in the light and dark schemes.
- **Moderation:** edit, delete, lock, pin and move; rate limits and bans; administration pages and a command line.
- **Small:** a static binary under 10 MB that idles in a few tens of megabytes of memory, on a small VPS behind [Xenia](https://xenia-platform.github.io), Caddy or Nginx.

New to RustBB? [Getting started](getting-started.md) goes from an empty server to a forum over HTTPS.

## Installing

Archives for Linux (static, x86_64 and arm64), macOS and Windows are in [the releases](https://github.com/rustbb/releases/releases), signed with cosign. On a Linux server with systemd, see [Getting started](getting-started.md) or [Deployment](deployment.md).

The [Docker image](docker.md), for amd64 and arm64:

```sh
docker run -d -p 8080:8080 -v rustbb:/var/lib/rustbb --env-file env ofkindness/rustbb:0.4.0
```

## Documentation

- [Getting started](getting-started.md): a forum on a fresh server, step by step.
- [Telegram](telegram.md): the bot, the first administrator, invitations and requests.
- [Configuration](configuration.md): every setting.
- [Deployment](deployment.md): systemd, a web server in front, backups.
- [Docker](docker.md): the image, a Compose file and the command line in a container.
- [Command line](command-line.md): users, invitations, requests and backups.
- [Monitoring](monitoring.md): logs, Prometheus metrics and crashes.
- [Upgrading](upgrading.md): backups, migrations and checking a download.
- [Privacy](privacy.md): what RustBB stores, data exports and deleting accounts.
- [Security](security.md): what RustBB does to keep a forum and its members safe.
- [Changelog](changelog.md): what changed in each release.

## License

RustBB is free to use for any purpose, including hosting forums for others, under the [RustBB License](https://github.com/rustbb/releases/blob/main/LICENSE). It is closed source; the releases and these docs are public.
