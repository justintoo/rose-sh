: ${DEV86_DEPENDENCIES:=}
: ${DEV86_CONFIGURE_OPTIONS:=
  }
: ${DEV86_TARBALL:="dev86-2c95336.tar.gz"}
: ${DEV86_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/bin/as86"}

#-------------------------------------------------------------------------------
install_dev86()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${DEV86_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${DEV86_INSTALLED_FILE}" ]; then
      rm -rf "./dev86"                           || fail "Unable to remove application workspace"
      mkdir -p "dev86"                           || fail "Unable to create application workspace"
      cd "dev86/"                                || fail "Unable to change into the application workspace"

      download_tarball "${DEV86_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${DEV86_TARBALL}"                || fail "Unable to unpack application tarball"

      cd "$(basename ${DEV86_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      make -j1 PREFIX="${ROSE_SH_DEPS_PREFIX}"     || fail "Unable to configure application"
      make -j${parallelism} install                             || fail "An error occurred during application installation"
  else
      info "[SKIP] dev86 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
