: ${LIBSSH2_DEPENDENCIES:=zlib libgcrypt libgpg_error openssl}
: ${LIBSSH2_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-libgcrypt
    --with-libgcrypt-prefix="$ROSE_SH_DEPS_PREFIX"
    --with-libz
    --with-libz-prefix="$ROSE_SH_DEPS_PREFIX"
    --with-libssl-prefix="$ROSE_SH_DEPS_PREFIX"
  }
: ${LIBSSH2_TARBALL:="libssh2-1.4.3.tar.gz"}
: ${LIBSSH2_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/libssh2.h"}

#-------------------------------------------------------------------------------
install_libssh2()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBSSH2_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBSSH2_INSTALLED_FILE}" ]; then
      rm -rf "./libssh2"                           || fail "Unable to create application workspace"
      mkdir -p "libssh2"                           || fail "Unable to create application workspace"
      cd "libssh2/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBSSH2_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBSSH2_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBSSH2_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBSSH2_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libssh2 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
