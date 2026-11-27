#!/usr/bin/env bash
set -e

APP="mmp-player"
VER="1.1"
OUT="dist"
rm -rf "$OUT" build_tmp
mkdir -p "$OUT" build_tmp

echo "📦 1. Generare arhivă sursă bilingvă (RO + EN + GPL v3)..."
tar -czf "$OUT/MMP-Player-${VER}-RO-EN-GPLv3.tar.gz" src assets LICENSE install.sh

echo "📦 2. Generare installer universal Linux (.run)..."
cat << 'RUNHDR' > "$OUT/MMP-Player-${VER}-Linux-Universal.run"
#!/usr/bin/env bash
set -e
TMPDIR="$(mktemp -d /tmp/mmp-player-install.XXXXXX)"
trap 'rm -rf "$TMPDIR"' EXIT
ARCHIVE_LINE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0")
tail -n +"$ARCHIVE_LINE" "$0" | tar -xz -C "$TMPDIR"
bash "$TMPDIR/install.sh" "$@"
exit 0
__ARCHIVE_BELOW__
RUNHDR
cat "$OUT/MMP-Player-${VER}-RO-EN-GPLv3.tar.gz" >> "$OUT/MMP-Player-${VER}-Linux-Universal.run"
chmod +x "$OUT/MMP-Player-${VER}-Linux-Universal.run"

# 3. Pachet .deb (Debian / Ubuntu / Mint)
if command -v dpkg-deb >/dev/null 2>&1; then
    echo "📦 3. Construire pachet .deb..."
    DEB="build_tmp/deb"
    mkdir -p "$DEB/DEBIAN" "$DEB/usr/bin" "$DEB/usr/share/applications" "$DEB/usr/share/icons/hicolor/scalable/apps" "$DEB/usr/share/doc/$APP"
    cp src/mmp-player "$DEB/usr/bin/$APP"
    cp assets/mmp-player.desktop "$DEB/usr/share/applications/"
    cp assets/mmp-player.png "$DEB/usr/share/icons/hicolor/scalable/apps/"
    cp LICENSE "$DEB/usr/share/doc/$APP/copyright"
    cat << CTRL > "$DEB/DEBIAN/control"
Package: $APP
Version: $VER
Section: video
Priority: optional
Architecture: all
Depends: python3, python3-pyqt6, libmpv2 | libmpv1, python3-mpv | python3-pip
Maintainer: MMP Player Contributors <mmp-player@example.org>
Homepage: https://gnu.org
Description: MMP Player (Multimedia Player) - GPL-3.0
 Multimedia player built with PyQt6 and libmpv (RO/EN bilingual).
 Licensed under GNU General Public License v3.0.
CTRL
    dpkg-deb --root-owner-group --build "$DEB" "$OUT/${APP}_${VER}_all.deb"
fi

# 4. Pachet Arch Linux (.pkg.tar.zst)
if command -v makepkg >/dev/null 2>&1; then
    echo "📦 4. Construire pachet Arch Linux (.pkg.tar.zst)..."
    mkdir -p build_tmp/arch
    cp src/mmp-player assets/mmp-player.desktop assets/mmp-player.png LICENSE build_tmp/arch/
    cat << 'PKGBUILD' > build_tmp/arch/PKGBUILD
pkgname=mmp-player
pkgver=1.1
pkgrel=1
pkgdesc="MMP Player (Multimedia Player) powered by PyQt6 and libmpv (RO/EN)"
arch=('any')
license=('GPL-3.0-or-later')
depends=('python' 'python-pyqt6' 'mpv' 'python-mpv')
source=('mmp-player' 'mmp-player.desktop' 'mmp-player.png' 'LICENSE')
sha256sums=('SKIP' 'SKIP' 'SKIP' 'SKIP')
package() {
    install -Dm755 "$srcdir/mmp-player" "$pkgdir/usr/bin/mmp-player"
    install -Dm644 "$srcdir/mmp-player.desktop" "$pkgdir/usr/share/applications/mmp-player.desktop"
    install -Dm644 "$srcdir/mmp-player.png" "$pkgdir/usr/share/icons/hicolor/256x256/apps/mmp-player.png"
    install -Dm644 "$srcdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
PKGBUILD
    (cd build_tmp/arch && makepkg -f --nodeps && cp *.pkg.tar.* "../../$OUT/")
fi

# 5. Pachet .rpm (Fedora / openSUSE / RHEL)
if command -v rpmbuild >/dev/null 2>&1; then
    echo "📦 5. Construire pachet .rpm..."
    RPMTOP="$(pwd)/build_tmp/rpm"
    mkdir -p "$RPMTOP"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    cp src/mmp-player assets/mmp-player.desktop assets/mmp-player.png LICENSE "$RPMTOP/SOURCES/"
    cat << SPEC > "$RPMTOP/SPECS/$APP.spec"
Name:           $APP
Version:        $VER
Release:        1%{?dist}
Summary:        MMP Player (Multimedia Player) powered by PyQt6 and libmpv
License:        GPL-3.0-or-later
BuildArch:      noarch
Requires:       python3, python3-qt6, mpv-libs
Source0:        mmp-player
Source1:        mmp-player.desktop
Source2:        mmp-player.png
Source3:        LICENSE

%description
MMP Player (Multimedia Player) with bilingual RO/EN interface, powered by PyQt6 and libmpv.

%install
install -Dm755 %{SOURCE0} %{buildroot}/usr/bin/mmp-player
install -Dm644 %{SOURCE1} %{buildroot}/usr/share/applications/mmp-player.desktop
install -Dm644 %{SOURCE2} %{buildroot}/usr/share/icons/hicolor/256x256/apps/mmp-player.png
install -Dm644 %{SOURCE3} %{buildroot}/usr/share/licenses/mmp-player/LICENSE

%files
%license /usr/share/licenses/mmp-player/LICENSE
/usr/bin/mmp-player
/usr/share/applications/mmp-player.desktop
/usr/share/icons/hicolor/256x256/apps/mmp-player.png
SPEC
    rpmbuild --define "_topdir $RPMTOP" -bb "$RPMTOP/SPECS/$APP.spec"
    find "$RPMTOP/RPMS" -name "*.rpm" -exec cp {} "$OUT/" \;
fi

# 6. AppImage (daca appimagetool este instalat)
if command -v appimagetool >/dev/null 2>&1; then
    echo "📦 6. Construire AppImage..."
    APPDIR="build_tmp/MMP-Player.AppDir"
    mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/share/licenses/mmp-player"
    cp src/mmp-player "$APPDIR/usr/bin/mmp-player"
    cp assets/mmp-player.desktop "$APPDIR/"
    cp assets/mmp-player.png "$APPDIR/"
    cp LICENSE "$APPDIR/usr/share/licenses/mmp-player/LICENSE"
    cat << 'APPRUN' > "$APPDIR/AppRun"
#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "${0}")")"
exec python3 "$HERE/usr/bin/mmp-player" "$@"
APPRUN
    chmod +x "$APPDIR/AppRun"
    ARCH=x86_64 appimagetool "$APPDIR" "$OUT/MMP-Player-${VER}-x86_64.AppImage"
fi

rm -rf build_tmp
echo ""
echo "✅ Toate pachetele au fost generate în folderul MMP-Player-1.1/$OUT/:"
ls -lh "$OUT"
