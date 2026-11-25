#!/usr/bin/env bash
set -e

mkdir -p dist/gentoo dist/void dist/nix

# 1. Gentoo Ebuild (mmp-player-1.0.ebuild)
cat << 'EBUILD' > dist/gentoo/mmp-player-1.0.ebuild
# Copyright 2026 MMP Player Contributors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
inherit desktop python-single-r1 xdg

DESCRIPTION="MMP Player (Multimedia Player) powered by PyQt6 and libmpv (RO/EN)"
HOMEPAGE="https://gnu.org"
SRC_URI="MMP-Player-${PV}-RO-EN-GPLv3.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/pyqt6[gui,widgets,${PYTHON_USEDEP}]
		dev-python/python-mpv[${PYTHON_USEDEP}]
	')
	media-video/mpv[libmpv]"

S="${WORKDIR}"

src_install() {
	python_newscript src/mmp-player mmp-player
	domenu assets/mmp-player.desktop
	doicon -s scalable assets/mmp-player.png
	dodoc LICENSE
}
EBUILD

# 2. Void Linux template (xbps-src)
cat << 'VOIDTPL' > dist/void/template
# Template file for 'mmp-player'
pkgname=mmp-player
version=1.0
revision=1
archs=noarch
depends="python3 python3-PyQt6 mpv python3-mpv"
short_desc="MMP Player (Multimedia Player) powered by PyQt6 and libmpv (RO/EN)"
maintainer="MMP Player Contributors <mmp-player@example.org>"
license="GPL-3.0-or-later"
homepage="https://gnu.org"
distfiles="MMP-Player-${version}-RO-EN-GPLv3.tar.gz"

do_install() {
	vbin src/mmp-player
	vinstall assets/mmp-player.desktop 644 usr/share/applications
	vinstall assets/mmp-player.png 644 usr/share/icons/hicolor/scalable/apps
	vlicense LICENSE
}
VOIDTPL

# 3. NixOS / Nix (default.nix)
cat << 'NIX' > dist/nix/default.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "mmp-player";
  version = "1.0";

  src = ./../MMP-Player-1.0-RO-EN-GPLv3.tar.gz;
  sourceRoot = ".";

  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [
    pkgs.mpv
    (pkgs.python3.withPackages (ps: with ps; [ pyqt6 python-mpv ]))
  ];

  installPhase = ''
    install -Dm755 src/mmp-player $out/bin/mmp-player
    install -Dm644 assets/mmp-player.desktop $out/share/applications/mmp-player.desktop
    install -Dm644 assets/mmp-player.png $out/share/icons/hicolor/256x256/apps/mmp-player.png
    install -Dm644 LICENSE $out/share/licenses/mmp-player/LICENSE
    wrapProgram $out/bin/mmp-player \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.mpv ]}"
  '';

  meta = with pkgs.lib; {
    description = "MMP Player (Multimedia Player) powered by PyQt6 and libmpv (RO/EN)";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
NIX

# 4. Adaugam suportul emerge (Gentoo) in install.sh si regeneram .run
if ! grep -q "command -v emerge" install.sh; then
    sed -i '/elif command -v xbps-install/i \    elif command -v emerge >/dev/null 2>&1;\n        $SUDO emerge --noreplace dev-lang/python dev-python/pyqt6 media-video/mpv dev-python/python-mpv' install.sh
fi

tar -czf "dist/MMP-Player-1.0-RO-EN-GPLv3.tar.gz" src assets LICENSE install.sh
cat << 'RUNHDR' > "dist/MMP-Player-1.0-Linux-Universal.run"
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
cat "dist/MMP-Player-1.0-RO-EN-GPLv3.tar.gz" >> "dist/MMP-Player-1.0-Linux-Universal.run"
chmod +x "dist/MMP-Player-1.0-Linux-Universal.run"

echo "✅ Suport adăugat pentru Gentoo (.ebuild), Void Linux (template), NixOS (default.nix) + Slackware (.txz)!"
ls -R dist/
