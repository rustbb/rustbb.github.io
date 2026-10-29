# Command line

The `rustbb` binary is the server and its administration tool. Without a command it runs the server.

```text
rustbb serve                         # the default
rustbb migrate                       # back up, apply pending migrations and exit
rustbb migrate --dry-run             # show what migrate would do; change nothing
rustbb user list
rustbb user role <name> admin        # user | moderator | admin
rustbb user ban <name>               # also ends their sessions
rustbb user unban <name>
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

The commands read the same [settings](configuration.md) as the server and open the same database, so give them the same environment. `request approve` sends a Telegram message, so it needs the bot settings as well.

Like the server, every command that opens the database, except `backup` and `migrate --dry-run`, first applies any pending migrations, with the [automatic backup](upgrading.md#the-automatic-backup) before them. `backup` copies the database as it is.

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
