#!/bin/sh
# Installs RustBB from its public release (https://rustbb.github.io):
#
#   curl -fsSLO https://rustbb.github.io/install.sh && sh install.sh
#
# It downloads the archive for this system and SHA256SUMS from
# github.com/rustbb/releases, refuses an archive whose checksum is not the
# one listed, and checks SHA256SUMS's signature too when cosign is
# installed. Then:
#
#   Linux with systemd, as root: /usr/local/bin/rustbb, the systemd unit
#   /etc/systemd/system/rustbb.service, and /etc/rustbb/env if there is
#   none (from env.example, 600). Not started: set up the forum first. An
#   upgrade restarts a running service, which backs up the database.
#
#   Otherwise (macOS, or without root): the binary only, into --dir
#   (/usr/local/bin when it can write there, else ~/.local/bin).
#
# Options:
#   --version X.Y.Z   that release, not the newest
#   --dir DIR         where the binary goes
#   --no-service      the binary only, even as root with systemd
#   --base URL        where the archives and SHA256SUMS are (for tests)
set -eu

repo=https://github.com/rustbb/releases
identity=https://github.com/rustbb/rustbb/.github/workflows/publish.yml@refs/heads/main
issuer=https://token.actions.githubusercontent.com
version=
dir=
service=true
base=

die() {
    echo "install.sh: $*" >&2
    exit 1
}
say() { echo "install.sh: $*"; }

while [ $# -gt 0 ]; do
    case $1 in
    --version) [ $# -ge 2 ] || die "--version needs a version"; version=${2#v}; shift 2 ;;
    --dir) [ $# -ge 2 ] || die "--dir needs a directory"; dir=$2; shift 2 ;;
    --no-service) service=false; shift ;;
    --base) [ $# -ge 2 ] || die "--base needs a URL"; base=$2; shift 2 ;;
    -h | --help) sed -n '2,/^set -eu/p' "$0" | sed -e '$d' -e 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown option $1 (see --help)" ;;
    esac
done

if command -v curl >/dev/null; then
    fetch() { curl -fsSL --proto '=https,file' -o "$2" "$1"; }
    fetch_text() { curl -fsSL --proto '=https' "$1"; }
elif command -v wget >/dev/null; then
    fetch() { wget -q -O "$2" "$1"; }
    fetch_text() { wget -q -O - "$1"; }
else
    die "needs curl or wget"
fi
if command -v sha256sum >/dev/null; then
    sha256() { sha256sum "$1" | cut -d' ' -f1; }
elif command -v shasum >/dev/null; then
    sha256() { shasum -a 256 "$1" | cut -d' ' -f1; }
else
    die "needs sha256sum or shasum"
fi

case $(uname -s) in
Linux) os=linux ;;
Darwin) os=macos ;;
*) die "no RustBB archive for $(uname -s); Windows has a .zip in $repo/releases" ;;
esac
case $(uname -m) in
x86_64 | amd64) arch=x86_64 ;;
aarch64 | arm64) arch=arm64 ;;
*) die "no RustBB archive for $(uname -m)" ;;
esac

if [ -z "$version" ]; then
    version=$(fetch_text https://api.github.com/repos/rustbb/releases/releases/latest |
        sed -n 's/.*"tag_name": *"v\([0-9][0-9.]*\)".*/\1/p' | head -n 1)
    [ -n "$version" ] || die "could not find the newest release; name one with --version"
fi
echo "$version" | grep -Eqx '[0-9]+\.[0-9]+\.[0-9]+' || die "$version is not a version such as 0.6.0"
[ -n "$base" ] || base=$repo/releases/download/v$version
name=rustbb-$version-$os-$arch

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
say "downloading RustBB $version for $os-$arch"
fetch "$base/SHA256SUMS" "$tmp/SHA256SUMS" || die "no SHA256SUMS at $base"
fetch "$base/$name.tar.gz" "$tmp/$name.tar.gz" || die "no $name.tar.gz at $base"

want=$(awk -v f="$name.tar.gz" '$2 == f || $2 == "*" f { print $1 }' "$tmp/SHA256SUMS")
echo "$want" | grep -Eqx '[0-9a-f]{64}' || die "SHA256SUMS lists no $name.tar.gz"
got=$(sha256 "$tmp/$name.tar.gz")
[ "$got" = "$want" ] || die "$name.tar.gz does not match SHA256SUMS: not installed"
if command -v cosign >/dev/null; then
    fetch "$base/SHA256SUMS.sigstore.json" "$tmp/SHA256SUMS.sigstore.json" ||
        die "no SHA256SUMS.sigstore.json at $base, though cosign is installed"
    cosign verify-blob "$tmp/SHA256SUMS" --bundle "$tmp/SHA256SUMS.sigstore.json" \
        --certificate-identity "$identity" --certificate-oidc-issuer "$issuer" >/dev/null 2>&1 ||
        die "the signature on SHA256SUMS does not check out: not installed"
    say "checked: the archive against SHA256SUMS, and its signature with cosign"
else
    say "checked: the archive against SHA256SUMS (install cosign to check its signature too)"
fi
tar -xzf "$tmp/$name.tar.gz" -C "$tmp"
src=$tmp/$name
"$src/rustbb" --version >/dev/null 2>&1 || die "the binary does not run here"

as_root=false
[ "$(id -u)" = 0 ] && as_root=true
if $service && $as_root && [ "$os" = linux ] && [ -d /run/systemd/system ] && [ -z "$dir" ]; then
    install -m 755 "$src/rustbb" /usr/local/bin/rustbb
    install -m 644 "$src/deploy/rustbb.service" /etc/systemd/system/rustbb.service
    if [ -f /etc/rustbb/env ]; then
        new_env=false
    else
        install -d -m 755 /etc/rustbb
        install -m 600 "$src/env.example" /etc/rustbb/env
        new_env=true
    fi
    systemctl daemon-reload
    say "installed $(/usr/local/bin/rustbb --version)"
    if systemctl --quiet is-active rustbb; then
        systemctl restart rustbb
        say "restarted the forum; journalctl -u rustbb -n 20 shows how it went"
    elif $new_env; then
        say "next: set up the forum in /etc/rustbb/env, then: systemctl enable --now rustbb"
        say "the docs: https://rustbb.github.io/getting-started/"
    else
        say "start it with: systemctl enable --now rustbb"
    fi
    exit 0
fi

if [ -z "$dir" ]; then
    if [ -w /usr/local/bin ]; then dir=/usr/local/bin; else dir=$HOME/.local/bin; fi
fi
mkdir -p "$dir"
install -m 755 "$src/rustbb" "$dir/rustbb"
[ "$os" != macos ] || xattr -d com.apple.quarantine "$dir/rustbb" 2>/dev/null || true
say "installed $("$dir/rustbb" --version) in $dir"
case ":$PATH:" in *":$dir:"*) ;; *) say "$dir is not on PATH" ;; esac
if [ "$os" = linux ]; then
    say "to run it as a service, run this as root on a system with systemd, or see https://rustbb.github.io/deployment/"
else
    say "to try it, see https://rustbb.github.io/getting-started/"
fi
