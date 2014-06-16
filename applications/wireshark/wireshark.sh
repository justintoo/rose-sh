
    #harfbuzz
    #geoip
    #geoip_database
    #libsmi
    #libc_ares
    #at_spi_atk
: ${WIRESHARK_DEPENDENCIES:=
    xcb_proto
    libxcb
    libpixman
    cairo
    atk
    intltool
    at_spi_core
    pango
    gdk_pixbuf
    gtk324
    libpcap
    libtool
  }
: ${WIRESHARK_CONFIGURE_OPTIONS:=
    --disable-gtktest
    --enable-wireshark
    --with-gtk3=yes
    --without-lua
    --without-qt
    --with-gcrypt
    --with-gnutls
    --with-libsmi
    --with-pcap
    --with-zlib
    --without-portaudio
    --without-libcap
    --without-krb5
    --with-cres
    --with-adns
    --with-geoip
  }

#-------------------------------------------------------------------------------
download_wireshark()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_wireshark()
#-------------------------------------------------------------------------------
{
  install_deps ${WIRESHARK_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_wireshark()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_wireshark__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      #ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ROSE_SH_DEPS_PREFIX}/share/libtool/libltdl:${ROSE_SH_DEPS_PREFIX}/share/libtool/config:${ACLOCAL_PATH}" \
      #./autogen.sh || fail "An error occurred during autotools bootstrapping"
      #ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ROSE_SH_DEPS_PREFIX}/share/libtool/libltdl:${ROSE_SH_DEPS_PREFIX}/share/libtool/config:${ACLOCAL_PATH}" \
      #autoreconf || fail "An error occurred during autotools bootstrapping"

      # TOO1 (2/12/2014): libtool.m4, pkg.m4 (pkg-config) must be found in the ACLOCAL_PATH.
      #ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ACLOCAL_PATH}" \
      #libtoolize --force --copy --ltdl --automake

      ## TOO1 (2/12/2014): libtool.m4, pkg.m4 (pkg-config) must be found in the ACLOCAL_PATH.
      #ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ACLOCAL_PATH}" \
      #    aclocal || fail "An error occurred during aclocal"

      ## TOO1 (2/12/2014): libtool.m4, pkg.m4 (pkg-config) must be found in the ACLOCAL_PATH.
      #ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ACLOCAL_PATH}" \
      #    autoconf || fail "An error occurred during application bootstrapping"

      ## TOO1 (2/12/2014) Requires AM_GLIB_GNU_GETTEXT
      #automake --add-missing --copy || fail "An error occurred during automake"

export PKG_CONFIG_PATH="${ROSE_SH_DEPS_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
      LIBTOOL="$(which libtool)" \
      CC="${ROSE_CC} -rose:unparse_in_same_directory_as_input_file" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS -I${ROSE_SH_DEPS_PREFIX}/include/gtk-3.0"  \
      LDFLAGS="$LDFLAGS -L${ROSE_SH_DEPS_PREFIX}/lib/gtk-3.0"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${WIRESHARK_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_wireshark__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      ./autogen.sh || fail "An error occurred during autotools bootstrapping"

      CC="${CC}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS -I${ROSE_SH_DEPS_PREFIX}/include/gtk-3.0"  \
      LDFLAGS="$LDFLAGS -L${ROSE_SH_DEPS_PREFIX}/lib/gtk-3.0"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${WIRESHARK_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_wireshark()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
