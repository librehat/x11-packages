TERMUX_PKG_HOMEPAGE=http://opencsg.org
TERMUX_PKG_DESCRIPTION="The CSG rendering library"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="Simeon Huang <symeon@librehat.com>"
TERMUX_PKG_VERSION=1.4.2
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL="http://www.opencsg.org/OpenCSG-${TERMUX_PKG_VERSION}.tar.gz"
TERMUX_PKG_SHA256=d952ec5d3a2e46a30019c210963fcddff66813efc9c29603b72f9553adff4afb
TERMUX_PKG_DEPENDS="mesa, glew"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="qt5-qtbase-cross-tools"

termux_step_configure () {
    cd "${TERMUX_PKG_SRCDIR}/src" && {
        "${TERMUX_PREFIX}/opt/qt/cross/bin/qmake" \
            -spec "${TERMUX_PREFIX}/lib/qt/mkspecs/termux-cross" \
            INSTALLDIR="${TERMUX_PREFIX}"
    }
}

termux_step_make() {
    cd "${TERMUX_PKG_SRCDIR}/src" && {
        make -j "${TERMUX_MAKE_PROCESSES}"
    }
}

termux_step_make_install() {
    cd "${TERMUX_PKG_SRCDIR}/src" && {
        make install
    }
}
