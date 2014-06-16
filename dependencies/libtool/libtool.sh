: ${LIBTOOL_DEPENDENCIES:=file}
: ${LIBTOOL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${LIBTOOL_TARBALL:="libtool-2.4.tar.gz"}
: ${LIBTOOL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/bin/libtool"}

#-------------------------------------------------------------------------------
install_libtool()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBTOOL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBTOOL_INSTALLED_FILE}" ]; then
      rm -rf "./libtool"                           || fail "Unable to remove old application workspace"
      mkdir -p "libtool"                           || fail "Unable to create application workspace"
      cd "libtool/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBTOOL_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBTOOL_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBTOOL_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBTOOL_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libtool is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
