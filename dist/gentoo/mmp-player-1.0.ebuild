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
