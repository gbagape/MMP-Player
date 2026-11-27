#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "Utilizare: ./publish.sh <VERSIUNE> \"<DESCRIERE>\" [REVIZIE_PPA]"
    echo "Exemplu:   ./publish.sh 1.2 \"Noutati in versiunea 1.2\" 1"
    exit 1
fi

VER="$1"
NOTES="${2:-Release v$VER}"
REV="${3:-1}"
KEY_ID="603695D77D2695354D5AA1E8C98014263D648421"
EMAIL="gbagape""@""gmail.com"

cd /home/gbagape/MMP-Player-1.0

echo "=== 1. Actualizare versiune la $VER in cod, README si sistem ==="
sed -i -E "s/MMP Player [0-9]+\.[0-9]+/MMP Player $VER/g; s/v[0-9]+\.[0-9]+/v$VER/g; s/ver = \"[0-9]+\.[0-9]+ \(local\)\"/ver = \"$VER (local)\"/g" src/mmp-player
sed -i -E "s/VER=\"[0-9]+\.[0-9]+\"/VER=\"$VER\"/g; s/mmp-player-[0-9]+\.[0-9]+/mmp-player-$VER/g; s/MMP-Player-[0-9]+\.[0-9]+/MMP-Player-$VER/g" packaging/*.sh

for f in README.md README_en.md README_ro.md; do
    if [ -f "$f" ]; then
        sed -i -E "s/v[0-9]+\.[0-9]+/v$VER/g; s/mmp-player_[0-9]+\.[0-9]+/mmp-player_$VER/g; s/mmp-player-[0-9]+\.[0-9]+/mmp-player-$VER/g; s/MMP-Player-[0-9]+\.[0-9]+/MMP-Player-$VER/g" "$f"
    fi
done

sudo cp src/mmp-player /usr/bin/mmp-player
sudo chmod 755 /usr/bin/mmp-player

echo "=== 2. Reconstruire pachete (Linux, macOS, Windows) ==="
MAC_OLD=$(ls dist/MMP-Player-*-macOS.app.zip 2>/dev/null | head -n 1)
if [ -n "$MAC_OLD" ]; then
    cp "$MAC_OLD" /tmp/macos_tpl.zip
fi

bash packaging/build_packages.sh
bash packaging/build_all_formats.sh
bash packaging/adauga_gentoo_void_nix.sh
bash packaging/genereaza_appimage_si_sha256.sh

# Pachet Arch Linux (.pkg.tar.zst)
mkdir -p build_tmp/arch/usr/bin build_tmp/arch/usr/share/applications build_tmp/arch/usr/share/icons/hicolor/256x256/apps build_tmp/arch/usr/share/licenses/mmp-player
cp src/mmp-player build_tmp/arch/usr/bin/mmp-player
cp assets/mmp-player.desktop build_tmp/arch/usr/share/applications/
cp assets/mmp-player.png build_tmp/arch/usr/share/icons/hicolor/256x256/apps/
cp LICENSE build_tmp/arch/usr/share/licenses/mmp-player/LICENSE
cat << PKG > build_tmp/arch/.PKGINFO
pkgname = mmp-player
pkgbase = mmp-player
pkgver = ${VER}-${REV}
pkgdesc = MMP Player (Multimedia Player) powered by PyQt6 and libmpv (RO/EN)
url = https://github.com
builddate = $(date +%s)
packager = gbagape <$EMAIL>
size = 250000
arch = any
license = GPL-3.0-or-later
depend = python
depend = python-pyqt6
depend = mpv
depend = python-mpv
PKG
tar --zstd -cf "dist/mmp-player-${VER}-${REV}-any.pkg.tar.zst" -C build_tmp/arch .PKGINFO usr

# Pachet macOS (.app.zip)
if [ -f /tmp/macos_tpl.zip ]; then
    mkdir -p build_tmp/macos
    unzip -q /tmp/macos_tpl.zip -d build_tmp/macos
    find build_tmp/macos -name "mmp-player" -exec cp src/mmp-player {} \;
    (cd build_tmp/macos && zip -qr "$OLDPWD/dist/MMP-Player-${VER}-macOS.app.zip" .)
    rm -f /tmp/macos_tpl.zip
fi

# Installer Windows (-Windows-Setup.exe)
if command -v makensis >/dev/null 2>&1 && [ -f packaging/windows/libmpv-2.dll ]; then
    mkdir -p build_tmp/win
    cp src/mmp-player build_tmp/win/mmp-player.pyw
    cp packaging/windows/libmpv-2.dll build_tmp/win/
    cp assets/mmp-player.png build_tmp/win/
    cp LICENSE build_tmp/win/
    python3 -c 'from PIL import Image; Image.open("assets/mmp-player.png").save("build_tmp/win/mmp-player.ico", format="ICO", sizes=[(16,16),(32,32),(48,48),(64,64),(128,128),(256,256)])' 2>/dev/null || true

    cat << 'BAT' > build_tmp/win/MMP-Player.bat
@echo off
cd /d "%~dp0"
where pythonw >nul 2>nul && (start "" pythonw mmp-player.pyw %* & exit /b)
where py >nul 2>nul && (start "" py -3 mmp-player.pyw %* & exit /b)
winget install -e --id Python.Python.3.12 --silent --accept-package-agreements --accept-source-agreements
py -3 -m pip install PyQt6 python-mpv yt-dlp
start "" py -3 mmp-player.pyw %*
BAT

    cat << NSI > build_tmp/win/installer.nsi
Unicode true
Name "MMP Player $VER"
OutFile "../../dist/MMP-Player-${VER}-Windows-Setup.exe"
InstallDir "\$PROGRAMFILES64\MMP Player"
RequestExecutionLevel admin
Page license
Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles
LicenseData "LICENSE"

Section "MMP Player $VER" SecMain
  SetOutPath "\$INSTDIR"
  File "mmp-player.pyw"
  File "MMP-Player.bat"
  File "libmpv-2.dll"
  File "mmp-player.png"
  File "LICENSE"
  IfFileExists "mmp-player.ico" 0 +2
    File "mmp-player.ico"
  CreateDirectory "\$SMPROGRAMS\MMP Player"
  CreateShortCut "\$SMPROGRAMS\MMP Player\MMP Player.lnk" "\$INSTDIR\MMP-Player.bat" "" "\$INSTDIR\mmp-player.ico"
  CreateShortCut "\$DESKTOP\MMP Player.lnk" "\$INSTDIR\MMP-Player.bat" "" "\$INSTDIR\mmp-player.ico"
  WriteUninstaller "\$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
  RMDir /r "\$INSTDIR"
  RMDir /r "\$SMPROGRAMS\MMP Player"
  Delete "\$DESKTOP\MMP Player.lnk"
SectionEnd
NSI
    makensis -V2 build_tmp/win/installer.nsi
fi

cp LICENSE dist/LICENSE
cp README.md dist/README.md
(
  cd dist
  rm -f SHA256SUMS MMP-Player-*-Complete-Release.zip MMP-Player-*-Complete-Release.zip.sha256
  find . -maxdepth 1 -type f ! -name 'SHA256SUMS' -exec sha256sum {} + | sed 's|\./||' | sort -k2 > SHA256SUMS
  zip -qr "MMP-Player-${VER}-Complete-Release.zip" .
  sha256sum "MMP-Player-${VER}-Complete-Release.zip" > "MMP-Player-${VER}-Complete-Release.zip.sha256"
)
rm -rf build_tmp

echo "=== 3. Publicare pe GitHub (cod + tag + Releases) ==="
git add -A
git commit -m "Release v${VER}-${REV}: $NOTES" || true
git tag -f "v$VER"
git push
git push -f origin "v$VER"

mapfile -t FILES < <(find dist -maxdepth 1 -type f | sort)
if gh release view "v$VER" >/dev/null 2>&1; then
    gh release upload "v$VER" "${FILES[@]}" --clobber
    gh release edit "v$VER" --title "MMP Player v$VER" --notes "$NOTES" --latest
else
    gh release create "v$VER" "${FILES[@]}" --title "MMP Player v$VER" --notes "$NOTES" --latest
fi

echo "=== 4. Publicare pe Launchpad PPA (Ubuntu 22.04, 24.04, 26.04) ==="
echo "test" | gpg --clearsign -u "$KEY_ID" > /dev/null

for SERIES in jammy noble resolute; do
    PPA_VER="${VER}-${REV}~${SERIES}1"
    cat << CHG > debian/changelog
mmp-player ($PPA_VER) $SERIES; urgency=medium

  * $NOTES

 -- gbagape <$EMAIL>  $(date -R)
CHG
    debuild -S -sa -k"$KEY_ID"
    dput ppa:gbagape/mmp-player "../mmp-player_${PPA_VER}_source.changes"
done

rm -f /home/gbagape/mmp-player_${VER}*
git add debian/changelog
git commit -m "Update debian/changelog to ${VER}-${REV}" || true
git push

echo "=== GATA! Versiunea $VER (revizia $REV) a fost publicata pe GitHub si Launchpad PPA! ==="
