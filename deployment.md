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

## Packages

Each of these sets up the same service, with the same unit and settings file; Homebrew, last, is for trying RustBB out:

- **The install script** downloads the archive for the machine and `SHA256SUMS` from the release, refuses an archive that does not match, checks the signature of `SHA256SUMS` too when [cosign](https://docs.sigstore.dev/cosign/system_config/installation/) is installed, and installs as the steps above do. Read it before running it:

  ```sh
  curl -fsSLO https://rustbb.github.io/install.sh
  sudo sh install.sh                  # --version 0.5.0 for another release; --help for the rest
  ```

  It does not start the forum on a new install. Run again, it upgrades: the settings stay, and a running forum restarts. Without root, or on macOS, it installs only the binary, into `~/.local/bin` or `--dir`.
- **Debian and Ubuntu** (amd64, arm64): the package `rustbb`, from the APT repository at `https://rustbb.github.io/apt`, so upgrades come with `apt upgrade`:

  ```sh
  sudo install -d -m 0755 /etc/apt/keyrings
  sudo curl -fsSLo /etc/apt/keyrings/rustbb.gpg https://rustbb.github.io/apt/rustbb.gpg
  printf 'Types: deb\nURIs: https://rustbb.github.io/apt\nSuites: stable\nComponents: main\nSigned-By: /etc/apt/keyrings/rustbb.gpg\n' |
    sudo tee /etc/apt/sources.list.d/rustbb.sources
  sudo apt update && sudo apt install rustbb
  ```

  The package suggests `xenia-server`, Xenia's package, as the web server in front: with [Xenia's APT repository](https://xenia-platform.github.io/apt/) added too, `sudo apt install rustbb xenia-server` sets up both. Without the repository, each release has the package as a file, covered by its signed `SHA256SUMS`: `sudo apt install ./rustbb_0.6.0_amd64.deb` (or `_arm64`). Installed that way, it upgrades from the repository once that is added.
- **Fedora and EL9/EL10** (Rocky Linux, AlmaLinux, RHEL; x86_64, aarch64): the package `rustbb`, from the dnf repository at `https://rustbb.github.io/rpm`, so upgrades come with `dnf upgrade`:

  ```sh
  sudo curl -fsSLo /etc/yum.repos.d/rustbb.repo https://rustbb.github.io/rpm/rustbb.repo
  sudo dnf install rustbb
  ```

  dnf checks the signature of each package and of the repository's metadata. Without the repository, each release has the package as a file, covered by `SHA256SUMS`: `sudo dnf install ./rustbb-0.6.0-1.x86_64.rpm` (or `.aarch64`). Those files are not signed themselves; the repository's copies are.
- **Homebrew** (macOS, and Linux), for trying RustBB out on your own computer: `brew install rustbb/tap/rustbb`, then `brew services start rustbb` runs a forum on `http://127.0.0.1:8080/`. Its settings are in `$(brew --prefix)/etc/rustbb/.env`, its database in `$(brew --prefix)/var/lib/rustbb`; restart it after changing them with `brew services restart rustbb`, and upgrade with `brew upgrade rustbb`. A forum on the internet runs on a Linux server, as above.

Both repositories are signed by RustBB's OpenPGP key, `8A5C 916C 2231 973F 4D69 F84D 675A 145E BCF4 5CC2`: `gpg --show-keys /etc/apt/keyrings/rustbb.gpg` shows it, and dnf shows it before importing it. They keep the last three releases, so `apt install rustbb=VERSION` or `dnf downgrade rustbb` can go back one or two, though not past a release that migrated the database ([Going back](upgrading.md#going-back)).

The packages install the binary as `/usr/bin/rustbb` (the install script and the archive use `/usr/local/bin/rustbb`; with a package, write `/usr/bin/rustbb` in [the command line's alias](command-line.md#on-a-server-with-systemd)), the unit as `/usr/lib/systemd/system/rustbb.service` and the settings as `/etc/rustbb/env`, readable by root only. They do not start the forum either: a new forum takes its name and registration mode from the settings when it first starts, so set it up first, check it, then:

```sh
sudo systemctl enable --now rustbb
```

An upgrade keeps edited settings and restarts a running forum, which backs up the database before migrating it ([Upgrading](upgrading.md)). Removing the package leaves the forum's data in `/var/lib/rustbb`; purging a Debian package removes `/etc/rustbb` too, never the data.

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
