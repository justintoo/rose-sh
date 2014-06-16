: ${GDBM_DEPENDENCIES:=}
: ${GDBM_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_PREFIX}/lib"
  }
: ${GDBM_TARBALL:="gdbm-1.10.tar.gz"}
: ${GDBM_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gdbm.h"}

#-------------------------------------------------------------------------------
install_gdbm()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GDBM_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GDBM_INSTALLED_FILE}" ]; then
      rm -rf "./gdbm"                           || fail "Unable to create application workspace"
      mkdir -p "gdbm"                           || fail "Unable to create application workspace"
      cd "gdbm/"                                || fail "Unable to change into the application workspace"

      download_tarball "${GDBM_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${GDBM_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${GDBM_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${GDBM_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] gdbm is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
