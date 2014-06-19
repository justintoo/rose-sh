: ${LIBGCRYPT_DEPENDENCIES:=libgpg_error}
: ${LIBGCRYPT_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-static
  }
: ${LIBGCRYPT_TARBALL:="libgcrypt-1.5.3.tar.gz"}
: ${LIBGCRYPT_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gcrypt.h"}

#-------------------------------------------------------------------------------
install_libgcrypt()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBGCRYPT_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBGCRYPT_INSTALLED_FILE}" ]; then
      rm -rf "./libgcrypt"                           || fail "Unable to create application workspace"
      mkdir -p "libgcrypt"                           || fail "Unable to create application workspace"
      cd "libgcrypt/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBGCRYPT_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBGCRYPT_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBGCRYPT_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBGCRYPT_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libgcrypt is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
