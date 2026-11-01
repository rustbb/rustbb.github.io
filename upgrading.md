# Upgrading

An upgrade replaces the binary or the image; the database stays where it is. Migrations run when the new version starts, after it has backed up the database.

## Before you upgrade

1. Read the [changelog](changelog.md) for every release since yours. Each one says whether it migrates the database.
2. Optionally, see what the new version would change: `rustbb migrate --dry-run`, run with the new binary and the forum's settings, lists the migrations it would apply and changes nothing. From 0.4 on, [`rustbb check`](command-line.md#checking-the-setup) checks the settings and the database too.
3. Make sure the disk has room for a second copy of the database: the automatic backup needs it.

## The automatic backup

When a new version finds migrations to apply, it first writes a copy of the database next to it, named after the version and the time, such as `rustbb-before-0.6.0-20261102T120000Z.db` in `/var/lib/rustbb/`. If the copy cannot be written, nothing is migrated and the forum does not start. The log says where the copy went.

These copies are not removed by RustBB. Keep the newest until the new version has run for a while, and delete older ones when you no longer need them. Your own regular backups ([Deployment](deployment.md#backups)) are separate.

## With systemd

Download and check the new archive as in [Getting started](getting-started.md#2-download-and-check-rustbb), then:

```sh
sudo install -m 755 rustbb /usr/local/bin/rustbb
sudo systemctl restart rustbb
journalctl -u rustbb -n 20    # the first line names the new version
```

With the [install script](deployment.md#packages), run it again instead; with a package, install the new one (`sudo apt install ./rustbb_….deb`, `sudo dnf install ./rustbb-….rpm`). Both restart a running forum.

Releases can be skipped: a new version applies every migration since yours, after one backup. From 1.0, settings, commands and addresses stay as they are across 1.x, so an upgrade within 1.x needs no changes to the setup ([Stability](stability.md)).

If you pinned `api.telegram.org` to an IPv4 address in `/etc/hosts` because 0.4 could not reach Telegram over a broken IPv6 route, remove that line after upgrading: later versions fall back to IPv4 by themselves ([Telegram](telegram.md#the-bot)).

## With Docker

```sh
docker pull ofkindness/rustbb:0.6.0
docker rm -f rustbb
docker run -d --name rustbb ...    # as before, with the new tag
```

## Going back

If the releases in between did not migrate the database, install the old binary or tag again. If one did, the old version refuses the migrated database. Stop the forum, put the automatic backup (or your own) in place of `rustbb.db`, remove the `rustbb.db-wal` and `rustbb.db-shm` files next to it, and start the old version. Anything posted since the upgrade is lost.

A version also refuses a database that a newer version migrated, rather than run on a schema it does not know.

## Checking a download

Every release is signed with [cosign](https://docs.sigstore.dev/cosign/system_config/installation/), without a key: the signature names the workflow that published the release. Check `SHA256SUMS` against its signature, then the archive against `SHA256SUMS`, all from the release:

```sh
cosign verify-blob SHA256SUMS --bundle SHA256SUMS.sigstore.json \
    --certificate-identity https://github.com/rustbb/rustbb/.github/workflows/publish.yml@refs/heads/main \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com
sha256sum -c --ignore-missing SHA256SUMS    # shasum -a 256 -c on macOS
```

The image is signed the same way, and carries its software bill of materials (CycloneDX) as a signed attestation:

```sh
cosign verify ofkindness/rustbb:0.6.0 \
    --certificate-identity https://github.com/rustbb/rustbb/.github/workflows/publish.yml@refs/heads/main \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

`rustbb --version` prints the version, the commit it was built from and the build date.
