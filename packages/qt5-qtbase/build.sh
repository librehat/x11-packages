TERMUX_PKG_HOMEPAGE=https://www.qt.io/
TERMUX_PKG_DESCRIPTION="A cross-platform application and UI framework"
TERMUX_PKG_LICENSE="LGPL-3.0"
TERMUX_PKG_MAINTAINER="Simeon Huang <symeon@librehat.com>"
TERMUX_PKG_VERSION=5.15.2
TERMUX_PKG_REVISION=7
TERMUX_PKG_SRCURL="https://download.qt.io/official_releases/qt/5.15/${TERMUX_PKG_VERSION}/submodules/qtbase-everywhere-src-${TERMUX_PKG_VERSION}.tar.xz"
TERMUX_PKG_SHA256=909fad2591ee367993a75d7e2ea50ad4db332f05e1c38dd7a5a274e156a4e0f8
TERMUX_PKG_DEPENDS="dbus, harfbuzz, libandroid-shmem, libc++, libice, libicu, libjpeg-turbo, libpng, libsm, libuuid, libx11, libxcb, libxi, libxkbcommon, openssl, pcre2, ttf-dejavu, freetype, xcb-util-image, xcb-util-keysyms, xcb-util-renderutil, xcb-util-wm, zlib"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_NO_STATICSPLIT=true

TERMUX_PKG_RM_AFTER_INSTALL="
bin/fixqt4headers.pl
bin/syncqt.pl
lib/qt/mkspecs/termux-cross
"

# Replacing the old qt5-base packages
TERMUX_PKG_REPLACES="qt5-base"
TERMUX_PKG_BREAKS="qt5-x11extras, qt5-tools, qt5-declarative"

TERMUX_PKG_QUICK_REBUILD=false

termux_step_pre_configure () {
    if [ "${TERMUX_ARCH}" = "arm" ]; then
        ## -mfpu=neon causes build failure on ARM.
        CFLAGS="${CFLAGS/-mfpu=neon/} -mfpu=vfp"
        CXXFLAGS="${CXXFLAGS/-mfpu=neon/} -mfpu=vfp"
    fi

    ## Create qmake.conf suitable for cross-compiling.
    sed \
        -e "s|@TERMUX_CC@|${TERMUX_HOST_PLATFORM}-clang|" \
        -e "s|@TERMUX_CXX@|${TERMUX_HOST_PLATFORM}-clang++|" \
        -e "s|@TERMUX_AR@|${TERMUX_HOST_PLATFORM}-ar|" \
        -e "s|@TERMUX_NM@|${TERMUX_HOST_PLATFORM}-nm|" \
        -e "s|@TERMUX_OBJCOPY@|${TERMUX_HOST_PLATFORM}-objcopy|" \
        -e "s|@TERMUX_PKGCONFIG@|${TERMUX_HOST_PLATFORM}-pkg-config|" \
        -e "s|@TERMUX_STRIP@|${TERMUX_HOST_PLATFORM}-strip|" \
        -e "s|@TERMUX_CFLAGS@|${CPPFLAGS} ${CFLAGS}|" \
        -e "s|@TERMUX_CXXFLAGS@|${CPPFLAGS} ${CXXFLAGS}|" \
        -e "s|@TERMUX_LDFLAGS@|${LDFLAGS}|" \
        "${TERMUX_PKG_BUILDER_DIR}/qmake.conf" > "${TERMUX_PKG_SRCDIR}/mkspecs/termux-cross/qmake.conf"
}

termux_step_configure () {
    unset CC CXX LD CFLAGS LDFLAGS PKG_CONFIG_PATH

    "${TERMUX_PKG_SRCDIR}"/configure -v \
        -opensource \
        -confirm-license \
        -debug \
        -optimized-tools \
        -xplatform termux-cross \
        -shared \
        -no-rpath \
        -no-use-gold-linker \
        -sysroot "${TERMUX_PREFIX}" \
        -prefix / \
        -docdir /share/doc/qt \
        -archdatadir /lib/qt \
        -datadir /share/qt \
        -plugindir /libexec/qt \
        -hostbindir "${TERMUX_PKG_SRCDIR}/hostbin" \
        -hostlibdir "${TERMUX_PKG_SRCDIR}/hostlib" \
        -nomake examples \
        -no-gcc-sysroot \
        -no-pch \
        -no-accessibility \
        -no-glib \
        -icu \
        -system-pcre \
        -system-zlib \
        -system-freetype \
        -ssl \
        -openssl-linked \
        -no-system-proxies \
        -no-cups \
        -system-harfbuzz \
        -no-opengl \
        -no-vulkan \
        -qpa xcb \
        -no-eglfs \
        -no-gbm \
        -no-kms \
        -no-linuxfb \
        -no-libudev \
        -no-evdev \
        -no-libinput \
        -no-mtdev \
        -no-tslib \
        -xcb \
        -gif \
        -system-libpng \
        -system-libjpeg \
        -system-sqlite \
        -sql-sqlite \
        -no-feature-systemsemaphore
}

termux_step_make() {
    make -j "${TERMUX_MAKE_PROCESSES}"
}

termux_step_make_install() {
    make install

    #######################################################
    ##
    ##  Compiling necessary libraries for target.
    ##
    #######################################################
    cd "${TERMUX_PKG_SRCDIR}/src/tools/bootstrap" && {
        make clean

        "${TERMUX_PKG_SRCDIR}/hostbin/qmake" \
            -spec "${TERMUX_PKG_SRCDIR}/mkspecs/termux-cross" \
            DEFINES+="QT_NO_SYSTEMSEMAPHORE"

        make -j "${TERMUX_MAKE_PROCESSES}"
        install -Dm644 ../../../lib/libQt5Bootstrap.a "${TERMUX_PREFIX}/lib/libQt5Bootstrap.a"
        install -Dm644 ../../../lib/libQt5Bootstrap.prl "${TERMUX_PREFIX}/lib/libQt5Bootstrap.prl"
    }

    #######################################################
    ##
    ##  Compiling necessary programs for target.
    ##
    #######################################################
    ## Note: qmake can be built only on host so it is omitted here.
    for i in moc qlalr qvkgen rcc uic; do
        cd "${TERMUX_PKG_SRCDIR}/src/tools/${i}" && {
            make clean

            "${TERMUX_PKG_SRCDIR}/hostbin/qmake" \
                -spec "${TERMUX_PKG_SRCDIR}/mkspecs/termux-cross"

            ## Ensure that no '-lpthread' specified in makefile.
            sed \
                -i 's@-lpthread@@g' \
                Makefile

            ## Fix build failure on at least 'i686'.
            sed \
                -i 's@$(LINK) $(LFLAGS) -o $(TARGET) $(OBJECTS) $(OBJCOMP) $(LIBS)@$(LINK) -o $(TARGET) $(OBJECTS) $(OBJCOMP) $(LIBS) $(LFLAGS) -lz@g' \
                Makefile

            make -j "${TERMUX_MAKE_PROCESSES}"
            install -Dm700 "../../../bin/${i}" "${TERMUX_PREFIX}/bin/${i}"
        }
    done
    unset i


    ## Unpacking prebuilt qmake from archive.
    cd "${TERMUX_PKG_SRCDIR}" && {
        tar xf "${TERMUX_PKG_BUILDER_DIR}/prebuilt.tar.xz"
        install \
            -Dm700 "${TERMUX_PKG_SRCDIR}/bin/qmake-${TERMUX_HOST_PLATFORM}" \
            "${TERMUX_PREFIX}/bin/qmake"
    }

    #######################################################
    ##
    ##  Fixes & cleanup.
    ##
    #######################################################

    ## Drop QMAKE_PRL_BUILD_DIR because reference the build dir.
    find "${TERMUX_PREFIX}/lib" -type f -name '*.prl' \
        -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' "{}" \;

    ## Remove *.la files.
    find "${TERMUX_PREFIX}/lib" -iname \*.la -delete

    ## Set qt spec path suitable for target.
    sed -i \
        's|/lib/qt//mkspecs/termux-cross"|/lib/qt/mkspecs/termux"|g' \
        "${TERMUX_PREFIX}/lib/cmake/Qt5Core/Qt5CoreConfigExtrasMkspecDir.cmake"
}

termux_step_create_debscripts() {
    ## FIXME: Qt should be built with fontconfig somehow instead
    ## of using direct path to fonts.
    ## Currently, using post-installation script to create symlink
    ## from /system/bin/fonts to $PREFIX/lib/fonts if possible.
    cp -f "${TERMUX_PKG_BUILDER_DIR}/postinst" ./
}

termux_step_post_massage() {
    #######################################################
    ##
    ##  Install host binaries and libraries to use later.
    ##
    #######################################################
    ## binaries
    for i in `ls "${TERMUX_PKG_SRCDIR}/hostbin/"`; do
        install \
            -Dm755 "${TERMUX_PKG_SRCDIR}/hostbin/${i}" \
            "${TERMUX_PREFIX}/bin/${i}"
    done
    unset i

    ## libraries
    for i in `ls "${TERMUX_PKG_SRCDIR}/hostlib/"`; do
        install \
            -Dm644 "${TERMUX_PKG_SRCDIR}/hostlib/${i}" \
            "${TERMUX_PREFIX}/lib/${i}"
    done
    unset i

    #######################################################
    ##
    ##  Restore qt spec path used for cross compiling.
    ##
    #######################################################
    sed -i \
        's|/lib/qt/mkspecs/termux"|/lib/qt/mkspecs/termux-cross"|g' \
        "${TERMUX_PREFIX}/lib/cmake/Qt5Core/Qt5CoreConfigExtrasMkspecDir.cmake"
}
