: ${LIBAIO_DEPENDENCIES:=}
: ${LIBAIO_CONFIGURE_OPTIONS:=
  }
: ${LIBAIO_TARBALL:="libaio-0.3.110.tar.gz"}
: ${LIBAIO_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/libaio.h"}

#-------------------------------------------------------------------------------
install_libaio()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBAIO_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBAIO_INSTALLED_FILE}" ]; then
      rm -rf "./libaio"                           || fail "Unable to remove application workspace"
      mkdir -p "libaio"                           || fail "Unable to create application workspace"
      cd "libaio/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBAIO_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBAIO_TARBALL}"                || fail "Unable to unpack application tarball"

      cd "$(basename ${LIBAIO_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      make install prefix="${ROSE_SH_DEPS_PREFIX}"       || fail "Unable to configure application"
  else
      info "[SKIP] libaio is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
