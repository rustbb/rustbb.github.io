# Docker

The image [`ofkindness/rustbb`](https://hub.docker.com/r/ofkindness/rustbb) holds the static binary and its licenses, nothing else, for amd64 and arm64. It runs as an unprivileged user, listens on port 8080 and keeps the database in the `/var/lib/rustbb` volume.

Tags: the version (`0.3.0`), the minor version (`0.3`) and `latest`. Every image is signed with cosign: see [Upgrading](upgrading.md#checking-a-download).

## Running it

Put the settings from [Configuration](configuration.md) in a file, `env`, without `RUSTBB_BIND` and `RUSTBB_DATABASE_PATH`, which the image sets:

```sh
RUSTBB_BASE_URL=https://forum.example.com
RUSTBB_TRUST_PROXY=1
RUSTBB_TELEGRAM_BOT_TOKEN=123456:ABC...
RUSTBB_TELEGRAM_BOT_USERNAME=example_forum_bot
RUSTBB_ADMIN_TELEGRAM_ID=123456789
```

Then:

```sh
docker run -d --name rustbb --restart unless-stopped \
    -p 127.0.0.1:8080:8080 -v rustbb:/var/lib/rustbb \
    --env-file env ofkindness/rustbb:0.3.0
```

Publishing the port on `127.0.0.1` keeps it for the web server on the same host, which handles HTTPS: see [Deployment](deployment.md#a-web-server-in-front).

## Compose

```yaml
services:
  rustbb:
    image: ofkindness/rustbb:0.3.0
    restart: unless-stopped
    env_file: env
    ports:
      - "127.0.0.1:8080:8080"
    volumes:
      - rustbb:/var/lib/rustbb
volumes:
  rustbb:
```

## The command line

The [command line](command-line.md) is the same binary, with the container's settings:

```sh
docker exec rustbb rustbb user list
docker exec rustbb rustbb backup /var/lib/rustbb/backup.db
docker cp rustbb:/var/lib/rustbb/backup.db .
```

## Upgrading

Back up first, then start a container from the new tag with the same volume; migrations run when it starts. See [Upgrading](upgrading.md).
