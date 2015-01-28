: ${IASL_DEPENDENCIES:=}
: ${IASL_CONFIGURE_OPTIONS:=
  }
: ${IASL_TARBALL:="acpica-unix-20141107.tar.gz"}
: ${IASL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/bin/iasl"}

#-------------------------------------------------------------------------------
install_iasl()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${IASL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${IASL_INSTALLED_FILE}" ]; then
      rm -rf "./iasl"                           || fail "Unable to remove application workspace"
      mkdir -p "iasl"                           || fail "Unable to create application workspace"
      cd "iasl/"                                || fail "Unable to change into the application workspace"

      download_tarball "${IASL_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${IASL_TARBALL}"                || fail "Unable to unpack application tarball"

      cd "$(basename ${IASL_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      make -j1 PREFIX="${ROSE_SH_DEPS_PREFIX}"            || fail "Unable to configure application"
      make -j1 PREFIX="${ROSE_SH_DEPS_PREFIX}" install    || fail "Unable to configure application"
  else
      info "[SKIP] iasl is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
