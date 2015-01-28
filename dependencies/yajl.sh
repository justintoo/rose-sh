: ${YAJL_DEPENDENCIES:=}
: ${YAJL_CONFIGURE_OPTIONS:=
  }
: ${YAJL_TARBALL:="lloyd-yajl-66cb08c.tar.gz"}
: ${YAJL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/yajl/yajl_version.h"}

#-------------------------------------------------------------------------------
install_yajl()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${YAJL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${YAJL_INSTALLED_FILE}" ]; then
      rm -rf "./yajl"                           || fail "Unable to remove application workspace"
      mkdir -p "yajl"                           || fail "Unable to create application workspace"
      cd "yajl/"                                || fail "Unable to change into the application workspace"

      download_tarball "${YAJL_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${YAJL_TARBALL}"                || fail "Unable to unpack application tarball"

      cd "$(basename ${YAJL_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure -p "${ROSE_SH_DEPS_PREFIX}"       || fail "Unable to configure application"
      make -j1                     || fail "An error occurred during application compilation"
      make -j1 install             || fail "An error occurred during application installation"
  else
      info "[SKIP] yajl is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
