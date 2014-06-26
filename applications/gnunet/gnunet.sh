: ${GNUNET_DEPENDENCIES:=curl openssl libmicrohttpd gettext sqlite3 mysql postgres libgcrypt libunistring libidn libextractor gmp zlib libxml2}
: ${GNUNET_CONFIGURE_OPTIONS:=
    --without-x
    --with-libgcrypt-prefix="${ROSE_SH_DEPS_PREFIX}"
    --with-libcurl="${ROSE_SH_DEPS_PREFIX}"
    --with-microhttpd="${ROSE_SH_DEPS_PREFIX}"
    --with-libidn="${ROSE_SH_DEPS_PREFIX}"
    --with-libunistring-prefix="${ROSE_SH_DEPS_PREFIX}"
    --with-sqlite="${ROSE_SH_DEPS_PREFIX}"
    --with-postgres="${ROSE_SH_DEPS_PREFIX}"
    --with-mysql="${ROSE_SH_DEPS_PREFIX}"
    --with-daemon-home-dir="$(pwd)/install_tree/var/lib/gnunet"
    --with-daemon-config-dir="$(pwd)/install_tree/etc"
    --without-sudo
    --with-gnunetdns=tm
  }

#-------------------------------------------------------------------------------
download_gnunet()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_gnunet()
#-------------------------------------------------------------------------------
{
  install_deps ${GNUNET_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_gnunet()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_gnunet__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${ROSE_CC}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              ${GNUNET_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_gnunet__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${CC}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${GNUNET_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_gnunet()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make -j${parallelism}         || fail "An error occurred during application compilation"
# TODO:
#      make -j${parallelism} install || fail "An error occurred during application installation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
