: ${SZIP_DEPENDENCIES:=}
: ${SZIP_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${SZIP_TARBALL:="szip-2.1.1.tar.gz"}
: ${SZIP_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/szlib.h"}

#-------------------------------------------------------------------------------
install_szip()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${SZIP_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${SZIP_INSTALLED_FILE}" ]; then
      rm -rf "./szip"                           || fail "Unable to remove old application workspace"
      mkdir -p "szip"                           || fail "Unable to create application workspace"
      cd "szip/"                                || fail "Unable to change into the application workspace"

      download_tarball "${SZIP_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${SZIP_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${SZIP_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${SZIP_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] szip is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
