TERMUX_PKG_HOMEPAGE=https://www.qt.io
TERMUX_PKG_DESCRIPTION="Python bindings for Qt 5 (PySide2)"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="Simeon Huang <symeon@librehat.com>"
TERMUX_PKG_VERSION=5.12.6
TERMUX_PKG_REVISION=0
TERMUX_PKG_SRCURL="https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-${TERMUX_PKG_VERSION}-src/pyside-setup-everywhere-src-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=53379f43891a6bc72fc344f5963d77de0916344637132aae634677dfbba185d8
TERMUX_PKG_DEPENDS="python, qt5-qtbase, qt5-qtmultimedia, qt5-qtsvg, qt5-qtlocation, qt5-qtx11extras, qt5-qtxmlpatterns, qt5-qttools, qt5-qtwebsockets, qt5-qtwebchannel, libxslt"
TERMUX_PKG_BUILD_DEPENDS="qt5-qtbase-cross-tools, qt5-qttools-cross-tools, cmake"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DPYTHON_EXECUTABLE=/usr/bin/python3.9"

termux_step_pre_configure () {
    export LLVM_INSTALL_DIR="${TERMUX_PREFIX}"
}
