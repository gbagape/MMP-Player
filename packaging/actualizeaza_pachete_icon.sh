#!/usr/bin/env bash
set -e

# 1. Actualizam install.sh sa instaleze toate dimensiunile PNG + pixmaps
python3 -c '
with open("install.sh", "r", encoding="utf-8") as f:
    s = f.read()

vechi = """$SUDO install -Dm644 "$DIR/assets/mmp-player.svg" "$PREFIX/share/icons/hicolor/scalable/apps/mmp-player.svg\""""
nou = """for sz in 16 24 32 48 64 128 256 512; do
    $SUDO install -Dm644 "$DIR/assets/icons/mmp-player-${sz}.png" "$PREFIX/share/icons/hicolor/${sz}x${sz}/apps/mmp-player.png"
done
$SUDO install -Dm644 "$DIR/assets/mmp-player.png" "$PREFIX/share/pixmaps/mmp-player.png\""""

s = s.replace(vechi, nou)
s = s.replace("\"$PREFIX/share/icons/hicolor/scalable/apps/mmp-player.svg\"", "\"$PREFIX/share/icons/hicolor/*/apps/mmp-player.png\" \"$PREFIX/share/pixmaps/mmp-player.png\"")
with open("install.sh", "w", encoding="utf-8") as f:
    f.write(s)
'

# 2. Actualizam scripturile de build sa foloseasca mmp-player.png in loc de .svg
for scr in build_packages.sh build_all_formats.sh adauga_gentoo_void_nix.sh; do
    if [[ -f "$scr" ]]; then
        sed -i 's|assets/mmp-player\.svg|assets/mmp-player.png|g' "$scr"
        sed -i 's|hicolor/scalable/apps/mmp-player\.svg|hicolor/256x256/apps/mmp-player.png|g' "$scr"
        sed -i 's|doicon -s scalable assets/mmp-player\.svg|newicon -s 256 assets/mmp-player.png mmp-player.png|g' "$scr"
    fi
done

# 3. Regeneram toate pachetele din dist/ cu noua iconita
./build_packages.sh
./build_all_formats.sh
./adauga_gentoo_void_nix.sh
cp README.md dist/README.md

echo ""
echo "✅ Gata! Noua iconiță este integrată în aplicație și în toate pachetele din dist/!"
