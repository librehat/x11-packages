TERMUX_PKG_HOMEPAGE=https://xorg.freedesktop.org/
TERMUX_PKG_DESCRIPTION="X11 damaged region extension library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=1.1.5
TERMUX_PKG_REVISION=18
TERMUX_PKG_SRCURL=https://xorg.freedesktop.org/releases/individual/lib/libXdamage-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=b734068643cac3b5f3d2c8279dd366b5bf28c7219d9e9d8717e1383995e0ea45
TERMUX_PKG_DEPENDS="libx11, libxau, libxcb, libxdmcp, libxfixes"
TERMUX_PKG_BUILD_DEPENDS="xorgproto"
