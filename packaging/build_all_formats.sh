#!/usr/bin/env bash
set -e

APP="mmp-player"
VER="1.1"
OUT="dist"
mkdir -p "$OUT" build_tmp

# 1. Pachet .deb (fara sa depinda de dpkg-deb, folosind ar + tar)
echo "📦 Construire pachet .deb (Debian / Ubuntu / Mint)..."
DEB="build_tmp/deb_data"
DEB_CTRL="build_tmp/deb_ctrl"
mkdir -p "$DEB/usr/bin" "$DEB/usr/share/applications" "$DEB/usr/share/icons/hicolor/scalable/apps" "$DEB/usr/share/doc/$APP" "$DEB_CTRL"
cp src/mmp-player "$DEB/usr/bin/$APP"
cp assets/mmp-player.desktop "$DEB/usr/share/applications/"
cp assets/mmp-player.png "$DEB/usr/share/icons/hicolor/scalable/apps/"
cp LICENSE "$DEB/usr/share/doc/$APP/copyright"
cat << CTRL > "$DEB_CTRL/control"
Package: $APP
Version: $VER
Section: video
Priority: optional
Architecture: all
Depends: python3, python3-pyqt6, libmpv2 | libmpv1, python3-mpv | python3-pip
Maintainer: MMP Player Contributors <mmp-player@example.org>
Description: MMP Player (Multimedia Player) - GPL-3.0
 Multimedia player built with PyQt6 and libmpv (RO/EN bilingual).
CTRL
echo "2.0" > build_tmp/debian-binary
tar -czf build_tmp/control.tar.gz -C "$DEB_CTRL" .
tar -czf build_tmp/data.tar.gz -C "$DEB" .
rm -f "$OUT/${APP}_${VER}_all.deb"
ar r "$OUT/${APP}_${VER}_all.deb" build_tmp/debian-binary build_tmp/control.tar.gz build_tmp/data.tar.gz >/dev/null 2>&1

# 2. Pachet Slackware (.txz)
echo "📦 Construire pachet Slackware (.txz)..."
SLK="build_tmp/slack"
mkdir -p "$SLK/usr/bin" "$SLK/usr/share/applications" "$SLK/usr/share/icons/hicolor/scalable/apps" "$SLK/usr/doc/$APP-$VER" "$SLK/install"
cp src/mmp-player "$SLK/usr/bin/$APP"
cp assets/mmp-player.desktop "$SLK/usr/share/applications/"
cp assets/mmp-player.png "$SLK/usr/share/icons/hicolor/scalable/apps/"
cp LICENSE "$SLK/usr/doc/$APP-$VER/LICENSE"
cat << DESC > "$SLK/install/slack-desc"
mmp-player: MMP Player (Multimedia Player) - GPL-3.0
mmp-player:
mmp-player: Bilingual (RO/EN) multimedia player powered by PyQt6 and libmpv.
DESC
tar -cJf "$OUT/${APP}-${VER}-noarch-1.txz" -C "$SLK" .

# 3. Pachet Alpine Linux (.apk)
echo "📦 Construire pachet Alpine Linux (.apk)..."
APK="build_tmp/alpine"
mkdir -p "$APK/usr/bin" "$APK/usr/share/applications" "$APK/usr/share/icons/hicolor/scalable/apps" "$APK/usr/share/licenses/$APP"
cp src/mmp-player "$APK/usr/bin/$APP"
cp assets/mmp-player.desktop "$APK/usr/share/applications/"
cp assets/mmp-player.png "$APK/usr/share/icons/hicolor/scalable/apps/"
cp LICENSE "$APK/usr/share/licenses/$APP/LICENSE"
cat << PKGINFO > "$APK/.PKGINFO"
pkgname = $APP
pkgver = ${VER}-r0
pkgdesc = MMP Player (Multimedia Player) - GPL-3.0
arch = noarch
license = GPL-3.0-or-later
depend = python3 py3-pyqt6 mpv-libs
PKGINFO
tar -czf "$OUT/${APP}-${VER}-r0.apk" -C "$APK" .PKGINFO usr

rm -rf build_tmp
echo ""
echo "✅ Toate pachetele disponibile acum în dist/:"
ls -lh "$OUT"
