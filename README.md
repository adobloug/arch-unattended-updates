# arch-unattended-updates

Gated unattended system upgrades for Arch Linux.

Arch is a rolling release with **no partial-upgrade support** and **no
security-only repository**. So this tool does not (and cannot safely) patch
"only security" while freezing the rest. Instead it runs a **full
`pacman -Syu`** — but only when it is safe to do so unattended — and otherwise
**holds the whole transaction** and pings you for manual review.

## Why this exists

If you come from Debian, you probably ran `unattended-upgrades` with a broad
`Origins-Pattern` (`label=Debian`, or even `o=*`) so *everything* got patched
automatically. Arch has no equivalent knob: there is no security-only repo and
partial upgrades are unsupported, so "auto-patch some of it" is not an option —
the only safe automatic action is a full `pacman -Syu`.

This tool provides that, with guardrails suited to a rolling release:

| Debian `unattended-upgrades` | Here |
|------------------------------|------|
| `Origins-Pattern` (which repos) | always the full official-repo `pacman -Syu` |
| `Package-Blacklist` | `BLACKLIST` (a match holds the *whole* upgrade) |
| — | Arch-news gate (`informant`) before upgrading |
| — | `snapper` + `snap-pac` snapshot for one-command rollback |

**AUR is out of scope.** Debian `o=*` would also pull third-party repos; the
Arch analog is the AUR, which means building unreviewed PKGBUILDs. That is not
safe to automate, so AUR packages stay manual (`yay -Syu` yourself).

## What it does

On a daily timer, as root:

1. `checkupdates` — list pending updates (never touches the real pacman DB).
   Nothing pending → exit.
2. `arch-audit` (optional) — tag how many pending pkgs have known CVEs.
3. **Gate A — Arch news:** if `informant` reports unread news → **hold + notify**.
4. **Gate B — blacklist:** if any pending pkg matches your blacklist → **hold + notify**.
5. Gates clear → `pacman -Syu --noconfirm`. `snap-pac` takes a btrfs snapshot
   automatically before/after, so rollback is always available.
6. Post-run: report `.pacnew` files to merge; recommend reboot if kernel /
   systemd / glibc changed (never auto-reboots).
7. Desktop notification to every logged-in graphical user.

## Why blacklist holds the *whole* upgrade

Freezing one package while upgrading the rest (`IgnorePkg`) is a **partial
upgrade** — unsupported on Arch, can break the system (libc/ABI skew). So when
a blacklisted package has an update, the entire run is held. You then upgrade
manually, inspecting the flagged package yourself.

## Install

### A. As a pacman package (recommended)

From the AUR:

```sh
yay -S arch-unattended-updates      # or your AUR helper of choice
```

Or build the release tarball directly:

```sh
makepkg -si            # from repo root; PKGBUILD fetches the tagged release tarball
```

Installs to `/usr/bin`, unit to `/usr/lib/systemd/system`, config to
`/etc/arch-unattended/config` (tracked as a pacman `backup` — your edits are
preserved across upgrades, new defaults land as `.pacnew`).

### B. Manual (no package)

```sh
pacman -S pacman-contrib libnotify snapper snap-pac
# optional: arch-audit (CVE tags), informant (AUR — Arch news gate)
sudo ./install.sh      # installs to /usr/local/bin, patches unit path
```

### Then (either method)

```sh
sudoedit /etc/arch-unattended/config      # set your blacklist
arch-unattended-update --dry-run          # report only, no changes, no root
sudo systemctl enable --now arch-unattended.timer
```

Requires `snapper` configured for `/` (and `snap-pac` for automatic snapshots)
to get the rollback safety net. See the Arch wiki: Snapper.

## Configuration

`/etc/arch-unattended/config` (bash syntax):

| Key | Meaning |
|-----|---------|
| `BLACKLIST` | glob patterns; a match holds the whole upgrade |
| `REBOOT_TRIGGERS` | pkgs that mean "reboot recommended" |
| `AUDIT` | `1` to CVE-tag via arch-audit |
| `CHECK_NEWS` | `1` to gate on unread Arch news (informant) |
| `REBOOT_POLICY` | `notify` (never auto-reboots) |
| `PACMAN_ARGS` | extra pacman flags |

## Operating

```sh
systemctl list-timers arch-unattended.timer   # when next
journalctl -t arch-unattended                 # what happened
cat /var/lib/arch-unattended/status.json      # last result
```

When held for a blacklisted package or news:

```sh
informant read        # if news gate tripped
pacman -Syu           # full manual upgrade, inspecting flagged pkgs
```

Rollback a bad upgrade (snap-pac + snapper):

```sh
snapper -c root list
snapper rollback <pre-snapshot-number>
reboot
```

## Notes / limits

- **No partial / security-only upgrades** — Arch design, not a tool limitation.
- **No auto-reboot** — flagged only; you decide.
- Desktop notifications need a graphical session; headless runs log via
  `journalctl -t arch-unattended` instead.
- `checkupdates` from `pacman-contrib` is required.
