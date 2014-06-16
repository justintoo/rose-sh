: ${LIBFFI_DEPENDENCIES:=}
: ${LIBFFI_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_PREFIX}/lib"
  }
: ${LIBFFI_TARBALL:="libffi-3.0.13.tar.gz"}
: ${LIBFFI_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/lib/libffi-3.0.13/include/ffi.h"}

#-------------------------------------------------------------------------------
install_libffi()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBFFI_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBFFI_INSTALLED_FILE}" ]; then
      rm -rf "./libffi"  || fail "Unable to remove old application workspace"
      mkdir -p "libffi"  || fail "Unable to create application workspace"
      cd "libffi/"       || fail "Unable to change into the application workspace"

      download_tarball "${LIBFFI_TARBALL}"    || fail "Unable to download application tarball"
      tar xzvf "${LIBFFI_TARBALL}"            || fail "Unable to unpack application tarball"
      cd "${LIBFFI_TARBALL%.tar.gz}"          || fail "Unable to change into application source directory"

      ./configure ${LIBFFI_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] libffi is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
