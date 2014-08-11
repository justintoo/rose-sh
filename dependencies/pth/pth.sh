: ${PTH_DEPENDENCIES:=libgpg_error}
: ${PTH_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${PTH_TARBALL:="pth-2.0.7.tar.gz"}
: ${PTH_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/pth.h"}

#-------------------------------------------------------------------------------
install_pth()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${PTH_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${PTH_INSTALLED_FILE}" ]; then
      rm -rf "./pth"                           || fail "Unable to create application workspace"
      mkdir -p "pth"                           || fail "Unable to create application workspace"
      cd "pth/"                                || fail "Unable to change into the application workspace"

      download_tarball "${PTH_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${PTH_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${PTH_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${PTH_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      # TOO1 (2/18/2014): Fails parallel build; dependency on pth_p.h not
      #                   properly setup in application Makefile.
      parallelism=1
      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] pth is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
