TERMUX_PKG_HOMEPAGE=http://openscad.org/
TERMUX_PKG_DESCRIPTION="The programmers solid 3D CAD modeller (Qt GUI build)"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_MAINTAINER="Simeon Huang <symeon@librehat.com>"
TERMUX_PKG_VERSION=2021.01
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://files.openscad.org/openscad-$TERMUX_PKG_VERSION.src.tar.gz
TERMUX_PKG_SHA256=d938c297e7e5f65dbab1461cac472fc60dfeaa4999ea2c19b31a4184f2d70359
TERMUX_PKG_DEPENDS="boost, cgal, double-conversion, fontconfig, harfbuzz, libzip, qt5-qtbase, qt5-qtmultimedia, qscintilla, mesa, glew, opencsg"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_BUILD_DEPENDS="qt5-qtbase-cross-tools, eigen"
# FIXME this depends on packages from science-packages

termux_step_configure () {
    export PKG_CONFIG_PATH="${TERMUX_PREFIX}/lib/pkgconfig/:${TERMUX_PREFIX}/share/pkgconfig/"

    # FIXME this requires Qt OpenGL
    "${TERMUX_PREFIX}/opt/qt/cross/bin/qmake" \
        -spec "${TERMUX_PREFIX}/lib/qt/mkspecs/termux-cross"
}
