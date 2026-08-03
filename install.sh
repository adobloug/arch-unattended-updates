#!/usr/bin/env bash
# install.sh — install arch-unattended-updates. Run as root on the target Arch box.
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "run as root" >&2; exit 1; }

SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

BIN=/usr/local/bin
CFG=/etc/arch-unattended
UNIT=/etc/systemd/system

echo ">> checking required dependencies"
missing=()
command -v checkupdates >/dev/null || missing+=("pacman-contrib")
command -v notify-send  >/dev/null || missing+=("libnotify")
command -v snapper      >/dev/null || missing+=("snapper (recommended: also snap-pac)")
if [[ ${#missing[@]} -gt 0 ]]; then
    echo "!! missing: ${missing[*]}"
    echo "   install with: pacman -S pacman-contrib libnotify snapper snap-pac"
    echo "   optional: arch-audit (CVE tagging), informant (AUR, news gate)"
    read -rp "Continue anyway? [y/N] " a
    [[ "$a" == [yY] ]] || exit 1
fi

echo ">> installing binaries -> $BIN"
install -Dm755 "$SRC/bin/arch-unattended-update" "$BIN/arch-unattended-update"
install -Dm755 "$SRC/bin/auu-notify"             "$BIN/auu-notify"

echo ">> installing config -> $CFG (existing config preserved)"
install -d "$CFG"
if [[ -e "$CFG/config" ]]; then
    install -Dm644 "$SRC/etc/arch-unattended/config" "$CFG/config.new"
    echo "   existing config kept; new default at $CFG/config.new"
else
    install -Dm644 "$SRC/etc/arch-unattended/config" "$CFG/config"
fi

echo ">> installing systemd units -> $UNIT (ExecStart patched to $BIN)"
# Shipped unit points at /usr/bin (package layout); manual install uses
# /usr/local/bin, so patch the ExecStart path.
sed "s#/usr/bin/arch-unattended-update#$BIN/arch-unattended-update#" \
    "$SRC/systemd/arch-unattended.service" > "$UNIT/arch-unattended.service"
chmod 644 "$UNIT/arch-unattended.service"
install -Dm644 "$SRC/systemd/arch-unattended.timer"   "$UNIT/arch-unattended.timer"

install -d /var/lib/arch-unattended

echo ">> reloading systemd"
systemctl daemon-reload

echo
echo "Installed. Next:"
echo "  1. edit blacklist:   \$EDITOR $CFG/config"
echo "  2. dry-run once:     arch-unattended-update"
echo "  3. enable timer:     systemctl enable --now arch-unattended.timer"
echo "  4. check schedule:   systemctl list-timers arch-unattended.timer"
