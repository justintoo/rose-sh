: ${OPENSSL_DEPENDENCIES:=zlib}
: ${OPENSSL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    shared
  }
: ${OPENSSL_TARBALL:="openssl-1.0.1e.tar.gz"}
: ${OPENSSL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/openssl/opensslconf.h"}

#-------------------------------------------------------------------------------
install_openssl()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${OPENSSL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${OPENSSL_INSTALLED_FILE}" ]; then
      rm -rf "./openssl"                            || fail "Unable to create application workspace"
      mkdir -p "openssl"                            || fail "Unable to create application workspace"
      cd "openssl/"                                 || fail "Unable to change into the application workspace"

      download_tarball "${OPENSSL_TARBALL}"         || fail "Unable to download application tarball"
      tar xzvf "${OPENSSL_TARBALL}"                 || fail "Unable to unpack application tarball"
      cd "$(basename ${OPENSSL_TARBALL%.tar.gz})"   || fail "Unable to change into application source directory"

      CC="gcc ${LDFLAGS}" \
          ./config        \
              ${OPENSSL_CONFIGURE_OPTIONS}          || fail "Unable to configure application"

      # Fails with parallel build
      make -j1                                      || fail "An error occurred during application compilation"
      make -j1 install                              || fail "An error occurred during application installation"
  else
      info "[SKIP] openssl is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
