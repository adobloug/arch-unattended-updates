# Maintainer: Andreas Dobloug <adobloug@gmail.com>
#
# Build from a release tarball:
#   makepkg -si
# Regenerate .SRCINFO after any change:
#   makepkg --printsrcinfo > .SRCINFO
pkgname=arch-unattended-updates
pkgver=0.1.1
pkgrel=1
pkgdesc="Gated unattended full-system upgrades for Arch (checkupdates + gates + notify)"
arch=('any')
url="https://github.com/adobloug/arch-unattended-updates"
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
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
# TODO(v0.1.1): after pushing the v0.1.1 tag, run `updpkgsums` to pin the real
# digest, then `makepkg --printsrcinfo > .SRCINFO`. 'SKIP' MUST NOT ship to AUR.
sha256sums=('SKIP')

package() {
    cd "$srcdir/$pkgname-$pkgver"

    install -Dm755 bin/arch-unattended-update \
        "$pkgdir/usr/bin/arch-unattended-update"
    install -Dm755 bin/auu-notify \
        "$pkgdir/usr/bin/auu-notify"

    install -Dm644 etc/arch-unattended/config \
        "$pkgdir/etc/arch-unattended/config"

    install -Dm644 systemd/arch-unattended.service \
        "$pkgdir/usr/lib/systemd/system/arch-unattended.service"
    install -Dm644 systemd/arch-unattended.timer \
        "$pkgdir/usr/lib/systemd/system/arch-unattended.timer"

    install -Dm644 README.md \
        "$pkgdir/usr/share/doc/$pkgname/README.md"

    install -Dm644 LICENSE \
        "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
