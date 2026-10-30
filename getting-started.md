# Getting started

From an empty Linux server to a forum at `https://forum.example.com`, with you as its administrator. It takes about fifteen minutes.

You need:

- A Linux server, x86_64 or arm64, with systemd: Debian or Ubuntu here. A small VPS is enough.
- A domain name whose DNS points at the server (an `A` record, and `AAAA` for IPv6).
- A Telegram account. Members sign in with Telegram; RustBB has no passwords.

## 1. Create the Telegram bot

The login widget belongs to a bot, which also sends you a message when someone asks for an invitation.

1. In Telegram, open [@BotFather](https://t.me/BotFather), send `/newbot` and follow its questions. Keep the token it gives you, and the bot's username.
2. Send BotFather `/setdomain`, choose the bot and give it `forum.example.com`. The login widget works only on that domain.
3. Find your own numeric Telegram id. The Telegram apps don't show it; a bot such as [@userinfobot](https://t.me/userinfobot) replies with it.

## 2. Download and check RustBB

On the server, download the archive for its architecture and the checksums, and check them:

```sh
VERSION=0.4.0
ARCH=x86_64    # or arm64
curl -fLO https://github.com/rustbb/releases/releases/download/v$VERSION/rustbb-$VERSION-linux-$ARCH.tar.gz
curl -fLO https://github.com/rustbb/releases/releases/download/v$VERSION/SHA256SUMS
sha256sum -c --ignore-missing SHA256SUMS
tar -xzf rustbb-$VERSION-linux-$ARCH.tar.gz
cd rustbb-$VERSION-linux-$ARCH
```

[Upgrading](upgrading.md#checking-a-download) shows how to check the signature of `SHA256SUMS` as well.

## 3. Install it as a service

```sh
sudo install -m 755 rustbb /usr/local/bin/rustbb
sudo mkdir -p /etc/rustbb
sudo install -m 600 env.example /etc/rustbb/env
sudo cp deploy/rustbb.service /etc/systemd/system/
```

Edit `/etc/rustbb/env`. These are the settings to change; [Configuration](configuration.md) lists the rest:

```sh
RUSTBB_BASE_URL=https://forum.example.com
RUSTBB_TRUST_PROXY=1
RUSTBB_TELEGRAM_BOT_TOKEN=123456:ABC...      # from BotFather
RUSTBB_TELEGRAM_BOT_USERNAME=example_forum_bot
RUSTBB_ADMIN_TELEGRAM_ID=123456789           # your own id
```

Check the settings. `rustbb check` explains anything that is wrong, and asks Telegram whether the bot token works:

```sh
sudo systemd-run --pipe --wait --quiet -p DynamicUser=yes -p StateDirectory=rustbb \
    -p EnvironmentFile=/etc/rustbb/env -E RUSTBB_DATABASE_PATH=/var/lib/rustbb/rustbb.db \
    /usr/local/bin/rustbb check
```

Fix every line marked `FAIL`, then start it:

```sh
sudo systemctl daemon-reload
sudo systemctl enable --now rustbb
systemctl status rustbb
```

RustBB now listens on `127.0.0.1:8080`, keeps its database in `/var/lib/rustbb/` and creates it on the first start.

## 4. Put Xenia in front

[Xenia](https://xenia-platform.github.io) receives the visitors, gets and renews the HTTPS certificate from Let's Encrypt, and passes requests to RustBB. Install it from its APT repository:

```sh
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSLo /etc/apt/keyrings/xenia.gpg https://xenia-platform.github.io/apt/xenia.gpg
printf 'Types: deb\nURIs: https://xenia-platform.github.io/apt\nSuites: stable\nComponents: main\nSigned-By: /etc/apt/keyrings/xenia.gpg\n' |
  sudo tee /etc/apt/sources.list.d/xenia.sources
sudo apt update && sudo apt install xenia-server
```

In `deploy/xenia.conf.js` from the archive, replace `forum.example.com` and the email address for Let's Encrypt, then install it and reload Xenia:

```sh
sudo install -o root -g xenia -m 640 deploy/xenia.conf.js /etc/xenia/xenia.conf.js
sudo xenia check /etc/xenia/xenia.conf.js && sudo systemctl reload xenia
```

Caddy or Nginx work as well: see [Deployment](deployment.md#a-web-server-in-front).

## 5. Sign in

Open `https://forum.example.com`, choose **Log in** and confirm in Telegram. Because your id is in `RUSTBB_ADMIN_TELEGRAM_ID`, you register without an invitation and become the administrator. Pick your forum username: it is independent of your Telegram username.

Under **Admin → Settings**, give the forum its name and a short description, and choose who can register: by invitation is the default. Then, under **Admin → Categories & forums**, create a category and a forum in it. The forum is ready.

## Next

- Invite people: Admin → Invitations, or let them ask from the registration page. See [Telegram](telegram.md#invitations).
- Back up the database regularly: [Deployment](deployment.md#backups).
- Before each upgrade, read [Upgrading](upgrading.md).
