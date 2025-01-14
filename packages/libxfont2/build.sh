TERMUX_PKG_HOMEPAGE=https://xorg.freedesktop.org/
TERMUX_PKG_DESCRIPTION="X11 font rasterisation library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=2.0.5
TERMUX_PKG_SRCURL=https://xorg.freedesktop.org/releases/individual/lib/libXfont2-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=aa7c6f211cf7215c0ab4819ed893dc98034363d7b930b844bb43603c2e10b53e
TERMUX_PKG_DEPENDS="freetype, libfontenc, zlib"
TERMUX_PKG_BUILD_DEPENDS="xorgproto, xorg-util-macros, xtrans"
