: ${ZLIB_DEPENDENCIES:=}
: ${ZLIB_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${ZLIB_TARBALL:="zlib-1.2.8.tar.gz"}
: ${ZLIB_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/zlib.h"}

#-------------------------------------------------------------------------------
install_zlib()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${ZLIB_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ZLIB_INSTALLED_FILE}" ]; then
      rm -rf "./zlib"                           || fail "Unable to remove old application workspace"
      mkdir -p "zlib"                           || fail "Unable to create application workspace"
      cd "zlib/"                                || fail "Unable to change into the application workspace"

      download_tarball "${ZLIB_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${ZLIB_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${ZLIB_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${ZLIB_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] zlib is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
