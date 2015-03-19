: ${SUBVERSION_DEPENDENCIES:=serf apr apr_util openldap cyrus_sasl db sqlite3 zlib neon file gettext}
: ${SUBVERSION_CONFIGURE_OPTIONS:=
  --with-apr="${ROSE_SH_DEPS_PREFIX}/bin/apr-1-config"
  --with-apr-util="${ROSE_SH_DEPS_PREFIX}/bin/apu-1-config"
  --with-serf="${ROSE_SH_DEPS_PREFIX}"
  --with-sqlite="${ROSE_SH_DEPS_PREFIX}"
  --with-sasl="${ROSE_SH_DEPS_PREFIX}"
  --with-libmagic="${ROSE_SH_DEPS_PREFIX}"
  --with-zlib="${ROSE_SH_DEPS_PREFIX}"
  --without-kwallet
  --without-gnome-keyring
  --disable-keychain
  --without-trang
  --without-doxygen
  --without-swig
  --without-jikes
  --without-ctypesgen
  --without-junit
  --without-jdk
  --without-apxs
  --with-editor="/usr/bin/vi"
  }

#-------------------------------------------------------------------------------
download_subversion()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_subversion()
#-------------------------------------------------------------------------------
{
  install_deps ${SUBVERSION_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_subversion()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_subversion__rose()
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
              --prefix="$(pwd)/install_tree" \
              ${SUBVERSION_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_subversion__gcc()
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
              ${SUBVERSION_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_subversion()
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
