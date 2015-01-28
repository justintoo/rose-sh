: ${LIBUUID_DEPENDENCIES:=}
: ${LIBUUID_CONFIGURE_OPTIONS:=
  }
: ${LIBUUID_TARBALL:="libuuid-1.0.3.tar.gz"}
: ${LIBUUID_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/uuid/uuid.h"}

#-------------------------------------------------------------------------------
install_libuuid()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBUUID_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBUUID_INSTALLED_FILE}" ]; then
      rm -rf "./libuuid"                           || fail "Unable to remove application workspace"
      mkdir -p "libuuid"                           || fail "Unable to create application workspace"
      cd "libuuid/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBUUID_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBUUID_TARBALL}"                || fail "Unable to unpack application tarball"

      cd "$(basename ${LIBUUID_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure --prefix="${ROSE_SH_DEPS_PREFIX}"       || fail "Unable to configure application"
      make -j${parallelism}         || fail "Unable to configure application"
      make -j${parallelism} install || fail "Unable to configure application"
  else
      info "[SKIP] libuuid is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
