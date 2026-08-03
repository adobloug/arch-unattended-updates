# Maintainer: Andreas Dobloug <adobloug@gmail.com>
#
# Build from a release tarball:
#   makepkg -si
# Regenerate .SRCINFO after any change:
#   makepkg --printsrcinfo > .SRCINFO
pkgname=arch-unattended-updates
pkgver=0.1.0
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
sha256sums=('b3aa0e2e7820e070c2b2d23bcc4492cfa3ac2a102905a7f0c17a74e2e90712a8')

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
