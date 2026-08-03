# Maintainer: Andreas Dobloug <andreas.dobloug@usit.uio.no>
#
# Local build:   makepkg -si         (run from this repo root)
#
# For AUR upload: replace the package()-from-$startdir copy with a real
# source=() tarball/git line (see the commented example below), then:
#   makepkg --printsrcinfo > .SRCINFO
pkgname=arch-unattended-updates
pkgver=0.1.0
pkgrel=1
pkgdesc="Gated unattended full-system upgrades for Arch (checkupdates + gates + notify)"
arch=('any')
url="https://example.com/arch-unattended-updates"  # TODO: real URL
license=('MIT')
depends=('pacman-contrib' 'libnotify' 'systemd')
optdepends=(
    'snapper: btrfs snapshots for rollback'
    'snap-pac: automatic pre/post pacman snapshots (recommended)'
    'arch-audit: tag CVE-affected packages in notifications'
    'informant: gate upgrades on unread Arch news'
)
backup=('etc/arch-unattended/config')
install="${pkgname}.install"

# --- AUR source example (uncomment + drop the $startdir copy in package) ----
# source=("$pkgname-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz")
# sha256sums=('SKIP')

package() {
    # Local packaging: files come straight from the repo (this dir).
    # $startdir is the directory containing this PKGBUILD.
    local src="$startdir"

    install -Dm755 "$src/bin/arch-unattended-update" \
        "$pkgdir/usr/bin/arch-unattended-update"
    install -Dm755 "$src/bin/auu-notify" \
        "$pkgdir/usr/bin/auu-notify"

    install -Dm644 "$src/etc/arch-unattended/config" \
        "$pkgdir/etc/arch-unattended/config"

    install -Dm644 "$src/systemd/arch-unattended.service" \
        "$pkgdir/usr/lib/systemd/system/arch-unattended.service"
    install -Dm644 "$src/systemd/arch-unattended.timer" \
        "$pkgdir/usr/lib/systemd/system/arch-unattended.timer"

    install -Dm644 "$src/README.md" \
        "$pkgdir/usr/share/doc/$pkgname/README.md"

    install -Dm644 "$src/LICENSE" \
        "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
