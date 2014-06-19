: ${LIBGPG_ERROR_DEPENDENCIES:=}
: ${LIBGPG_ERROR_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-static
  }
: ${LIBGPG_ERROR_TARBALL:="libgpg-error-1.12.tar.gz"}
: ${LIBGPG_ERROR_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gpg-error.h"}

#-------------------------------------------------------------------------------
install_libgpg_error()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBGPG_ERROR_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBGPG_ERROR_INSTALLED_FILE}" ]; then
      rm -rf "./libgpg_error"                           || fail "Unable to create application workspace"
      mkdir -p "libgpg_error"                           || fail "Unable to create application workspace"
      cd "libgpg_error/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBGPG_ERROR_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBGPG_ERROR_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBGPG_ERROR_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBGPG_ERROR_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libgpg_error is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
