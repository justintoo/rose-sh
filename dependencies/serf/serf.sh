: ${SERF_DEPENDENCIES:=zlib openssl apr apr_util}
: ${SERF_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-openssl="${ROSE_SH_DEPS_PREFIX}"
    --with-apr="${ROSE_SH_DEPS_PREFIX}/bin/apr-1-config"
    --with-apr-util="${ROSE_SH_DEPS_PREFIX}/bin/apu-1-config"
  }
: ${SERF_TARBALL:="serf-1.2.1.tar.bz2"}
: ${SERF_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/serf-1/serf.h"}

#-------------------------------------------------------------------------------
install_serf()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${SERF_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${SERF_INSTALLED_FILE}" ]; then
      rm -rf "./serf"  || fail "Unable to remove old application workspace"
      mkdir -p "serf"  || fail "Unable to create application workspace"
      cd "serf/"       || fail "Unable to change into the application workspace"

      download_tarball "${SERF_TARBALL}"        || fail "Unable to download application tarball"
      tar xjvf "${SERF_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${SERF_TARBALL%.tar.bz2})" || fail "Unable to change into application source directory"

      ./configure ${SERF_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] serf is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
