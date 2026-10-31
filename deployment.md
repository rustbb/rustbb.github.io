# Deployment

RustBB is one executable. It listens on a local port, keeps everything in one SQLite file, and leaves HTTPS to a web server in front of it. [Getting started](getting-started.md) walks through the whole setup; this page has the details.

## What it needs

One CPU and 1 GB of memory is plenty. Every change to RustBB is checked against a budget on a forum of 1,000 members, 2,000 topics and 50,000 posts: at a steady 100 requests a second, with the server on one CPU, 95% of pages are answered within 50 ms, and the server uses under 50 MB of memory. It typically uses under half of both. Processing an uploaded image takes more for a moment, up to a few hundred megabytes for a large photo; RustBB processes one at a time. The database of such a forum is about 28 MB, a quarter of it the search index; allow room for backups beside it. Searches are held to the same budget, even for a word in every post.

## systemd

Every Linux archive has a unit, [`deploy/rustbb.service`](https://github.com/rustbb/releases/blob/main/deploy/rustbb.service):

```sh
sudo install -m 755 rustbb /usr/local/bin/rustbb
sudo mkdir -p /etc/rustbb
sudo install -m 600 env.example /etc/rustbb/env    # then edit it
sudo cp deploy/rustbb.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now rustbb
```

The service runs as a dynamic user with no login and no home, under `ProtectSystem=strict`. It listens on `127.0.0.1:8080` and keeps the database in `/var/lib/rustbb/rustbb.db`, which systemd creates and owns for it. Migrations run on every start. Logs go to the journal: `journalctl -u rustbb`; [Monitoring](monitoring.md) has JSON logs and metrics.

To run the [command line](command-line.md#on-a-server-with-systemd) on such a server, run it as the service does, so the database files keep their owner.

## A web server in front

RustBB speaks plain HTTP on `127.0.0.1`. A web server in front takes the visitors, holds the HTTPS certificate and passes requests on. Behind any of them, set `RUSTBB_TRUST_PROXY=1` and the `https://` address in `RUSTBB_BASE_URL`.

### Xenia

[Xenia](https://xenia-platform.github.io) is the recommended one: it gets and renews Let's Encrypt certificates by itself, redirects plain HTTP to HTTPS, and replaces `X-Forwarded-For` with the visitor's address, so nobody can fake theirs. [`deploy/xenia.conf.js`](https://github.com/rustbb/releases/blob/main/deploy/xenia.conf.js) is a complete config for Xenia 0.17 or newer. Install Xenia from its APT repository on Debian or Ubuntu:

```sh
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSLo /etc/apt/keyrings/xenia.gpg https://xenia-platform.github.io/apt/xenia.gpg
printf 'Types: deb\nURIs: https://xenia-platform.github.io/apt\nSuites: stable\nComponents: main\nSigned-By: /etc/apt/keyrings/xenia.gpg\n' |
  sudo tee /etc/apt/sources.list.d/xenia.sources
sudo apt update && sudo apt install xenia-server
```

Replace the domain and the email address in the config, then:

```sh
sudo install -o root -g xenia -m 640 deploy/xenia.conf.js /etc/xenia/xenia.conf.js
sudo xenia check /etc/xenia/xenia.conf.js && sudo systemctl reload xenia
```

Point the domain's DNS at the server first: Let's Encrypt checks it. Xenia's [documentation](https://xenia-platform.github.io) covers FreeBSD, Homebrew and Docker as well.

### Caddy and Nginx

[`deploy/Caddyfile`](https://github.com/rustbb/releases/blob/main/deploy/Caddyfile) does the same with Caddy, which also gets certificates by itself. [`deploy/nginx.conf`](https://github.com/rustbb/releases/blob/main/deploy/nginx.conf) is a server block for Nginx on port 80; add HTTPS with your usual certificate tool. It sets `X-Forwarded-For` to the address Nginx saw, never to what the client sent.

## Feeds and search engines

Feed readers and search engines see what visitors see, whoever asks: forums for members or staff have no feeds and are left out of the sitemap.

| Address | |
| --- | --- |
| `/feed.atom`, `/feed.rss` | The newest 20 topics in the forum, each with its first post |
| `/f/{id}/feed.atom`, `/f/{id}/feed.rss` | The same for one forum |
| `/t/{id}/feed.atom`, `/t/{id}/feed.rss` | The newest 20 posts in a topic |
| `/sitemap.xml` | The front page, the forums and every topic, 10,000 topics to a file |
| `/robots.txt` | Keeps crawlers away from search, sign-in, settings and administration, and names the sitemap |

Pages link to their feeds, so browsers and feed readers find them from the address of the forum, a forum or a topic. Each page also names its canonical address, the one with the topic's or forum's current name in it, and carries OpenGraph tags, so a link pasted into a chat shows the topic's title, the start of its first post and its first image. All of these use `RUSTBB_BASE_URL`; check that it is the address visitors use.

Feeds can be cached for five minutes and answer `304 Not Modified` to a reader that already has the latest one. To keep a forum out of search engines and feeds, make it readable by signed-in members only (see [Who may read and post](moderation.md#who-may-read-and-post)).

## Backups

The forum is the database file and the uploads directory beside it (avatars and images in posts; `RUSTBB_UPLOADS_PATH`). `rustbb backup PATH` writes a consistent copy of the database while the forum runs; run it from cron or a systemd timer, as the service user (see [Command line](command-line.md#on-a-server-with-systemd)), and keep copies off the server. Copy the uploads directory too, after the database: its files never change once written, so `rsync` or any file backup will do, and a file missing from a backup only means a missing image. [Litestream](https://litestream.io) can stream the database to object storage continuously instead.

A new version backs the database up by itself before it migrates it: see [Upgrading](upgrading.md#the-automatic-backup). That copy sits next to the database, on the same disk, so it does not replace your own backups.

## Without a web server

For a test on a local network, RustBB can listen on all addresses itself: `RUSTBB_BIND=0.0.0.0:8080` and `RUSTBB_BASE_URL=http://<address>:8080`, with `RUSTBB_TRUST_PROXY=0`. Telegram login needs the domain set with BotFather, so a public forum needs its domain and HTTPS.
