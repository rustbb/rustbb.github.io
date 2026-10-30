# Command line

The `rustbb` binary is the server and its administration tool. Without a command it runs the server.

```text
rustbb serve                         # the default
rustbb check                         # check the settings, database and bot; change nothing
rustbb migrate                       # back up, apply pending migrations and exit
rustbb migrate --dry-run             # show what migrate would do; change nothing
rustbb user list
rustbb user role <name> admin        # user | moderator | admin
rustbb user ban <name>               # also ends their sessions
rustbb user ban <name> --reason "Spam" --days 7   # 0 days, the default, is for good
rustbb user unban <name>
rustbb user export <name>            # everything stored about them, as JSON
rustbb user delete <name>            # delete the account; --erase-posts erases their posts too
rustbb ip list                       # banned addresses
rustbb ip ban 203.0.113.0/24 --reason "Spam" --days 30
rustbb ip unban 203.0.113.0/24
rustbb invite create                 # one registration, no expiry
rustbb invite create --uses 5 --days 7
rustbb invite create --for alice     # for one Telegram account; no code to type
rustbb invite list
rustbb request list                  # people who asked for an invitation
rustbb request approve <id>          # invites them; the bot tells them
rustbb request decline <id>
rustbb backup /path/to/copy.db       # a consistent copy while the forum runs, as it is
rustbb licenses                      # licenses of the components in the binary
rustbb --version                     # version, commit and build date
rustbb help <command>
```

The commands read the same [settings](configuration.md) as the server and open the same database, so give them the same environment. `request approve` sends a Telegram message, so it needs the bot settings as well. `user export` and `user delete` are for requests under data protection law: see [Privacy](privacy.md). A running server applies `ip ban` and `ip unban` within a minute; account bans apply at once.

Like the server, every command that opens the database, except `backup` and `migrate --dry-run`, first applies any pending migrations, with the [automatic backup](upgrading.md#the-automatic-backup) before them. `backup` copies the database as it is.

## Checking the setup

`rustbb check` reads the settings like the server, then reports one line per check: `ok`, `warn` or `FAIL`, each with what to do about it.

```text
RustBB 0.3.0 (befd76d058 2026-10-29)
warn  base URL      RUSTBB_BASE_URL=http://forum.example.com is not https: sign-in cookies are sent unencrypted. ...
ok    telegram      bot @example_forum_bot
ok    proxy         listening on 127.0.0.1:8080; visitors' addresses come from the web server
ok    registration  INVITE: registration needs an invitation (set under Admin, Settings); Telegram id 123456789 can always register and becomes administrator
ok    database      /var/lib/rustbb/rustbb.db: up to date, 1.2 MB
FAIL  telegram API  Telegram rejects the token: copy it again from @BotFather (/mybots, API Token)
1 problem to fix, 1 warning
```

It checks the public address, the bot's token and username, the proxy setting against the listen address, the registration mode and first administrator, and the database: whether it opens, and whether migrations are pending or come from a newer version. It asks Telegram whether the token works and belongs to the named bot; `--offline` skips that. It creates and migrates nothing, and exits with status 1 if anything fails. Run it after changing the settings, and with a new binary before upgrading.

## On a server with systemd

The service runs as a dynamic user that owns the database. Run commands the same way, not as root, so the database files keep their owner:

```sh
sudo systemd-run --pipe --wait --quiet -p DynamicUser=yes -p StateDirectory=rustbb \
    -p EnvironmentFile=/etc/rustbb/env -E RUSTBB_DATABASE_PATH=/var/lib/rustbb/rustbb.db \
    /usr/local/bin/rustbb user list
```

A shell alias saves typing:

```sh
alias rustbb='sudo systemd-run --pipe --wait --quiet -p DynamicUser=yes -p StateDirectory=rustbb -p EnvironmentFile=/etc/rustbb/env -E RUSTBB_DATABASE_PATH=/var/lib/rustbb/rustbb.db /usr/local/bin/rustbb'
```

A backup written this way lands where the service user may write, such as `/var/lib/rustbb/`.

## In Docker

```sh
docker exec rustbb rustbb user list
```

See [Docker](docker.md#the-command-line).
