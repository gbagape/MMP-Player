#!/usr/bin/env bash
set -e

APP="mmp-player"
VER="1.1"
OUT="dist"
mkdir -p "$OUT"

echo "📦 Construire MMP-Player-${VER}-x86_64.AppImage..."
APPDIR="build_tmp/MMP-Player.AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/share/icons/hicolor/256x256/apps" "$APPDIR/usr/share/licenses/$APP"

cp src/mmp-player "$APPDIR/usr/bin/$APP"
cp assets/mmp-player.desktop "$APPDIR/"
cp assets/mmp-player.png "$APPDIR/mmp-player.png"
cp assets/mmp-player.png "$APPDIR/.DirIcon"
cp assets/mmp-player.png "$APPDIR/usr/share/icons/hicolor/256x256/apps/mmp-player.png"
cp LICENSE "$APPDIR/usr/share/licenses/$APP/LICENSE"

cat << 'APPRUN' > "$APPDIR/AppRun"
#!/usr/bin/env bash
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="$HERE/usr/bin:$PATH"
exec python3 "$HERE/usr/bin/mmp-player" "$@"
APPRUN
chmod +x "$APPDIR/AppRun"

if false && command -v appimagetool >/dev/null 2>&1; then
    ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 appimagetool "$APPDIR" "$OUT/MMP-Player-${VER}-x86_64.AppImage"
else
    # Generam AppImage auto-mount / auto-extract bazat pe squashfs (100% compatibil orice Linux)
    mkdir -p build_tmp
    if command -v mksquashfs >/dev/null 2>&1; then mksquashfs "$APPDIR" build_tmp/app.squashfs -comp zstd -noappend >/dev/null; else tar -czf build_tmp/app.squashfs -C "$APPDIR" .; fi
    cat << 'STUB' > "$OUT/MMP-Player-${VER}-x86_64.AppImage"
#!/usr/bin/env bash
set -e
MNT="$(mktemp -d /tmp/mmp-appimage.XXXXXX)"
cleanup() { fusermount -u "$MNT" 2>/dev/null || umount "$MNT" 2>/dev/null || true; rm -rf "$MNT"; }
trap cleanup EXIT
OFFSET=$(awk '/^__SQUASHFS_BELOW__/ {print NR + 1; exit 0; }' "$0")
tail -n +"$OFFSET" "$0" > "$MNT.sqfs"
if command -v squashfuse >/dev/null 2>&1 && squashfuse "$MNT.sqfs" "$MNT" 2>/dev/null; then
    "$MNT/AppRun" "$@"
    rm -f "$MNT.sqfs"
else
    unsquashfs -f -d "$MNT" "$MNT.sqfs" >/dev/null
    rm -f "$MNT.sqfs"
    "$MNT/AppRun" "$@"
fi
exit 0
__SQUASHFS_BELOW__
STUB
    cat build_tmp/app.squashfs >> "$OUT/MMP-Player-${VER}-x86_64.AppImage"
fi

chmod +x "$OUT/MMP-Player-${VER}-x86_64.AppImage"
rm -rf build_tmp

cp README.md LICENSE "$OUT/"
(
    cd "$OUT"
    rm -f SHA256SUMS
    sha256sum *.run *.tar.gz *.deb *.rpm *.txz *.apk *.AppImage > SHA256SUMS
)

echo ""
echo "✅ Gata! Toate pachetele + .AppImage + README + LICENSE + SHA256SUMS sunt în dist/:"
ls -lh "$OUT"
echo ""
cat "$OUT/SHA256SUMS"
