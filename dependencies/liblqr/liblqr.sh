: ${LIBLQR_DEPENDENCIES:=glib}
: ${LIBLQR_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-static
  }
: ${LIBLQR_TARBALL:="liblqr-1-0.4.2.tar.bz2"}
: ${LIBLQR_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/lqr-1/lqr.h"}

#-------------------------------------------------------------------------------
install_liblqr()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBLQR_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBLQR_INSTALLED_FILE}" ]; then
      rm -rf "./liblqr"  || fail "Unable to remove old application workspace"
      mkdir -p "liblqr"  || fail "Unable to create application workspace"
      cd "liblqr/"       || fail "Unable to change into the application workspace"

      download_tarball "${LIBLQR_TARBALL}"        || fail "Unable to download application tarball"
      tar xjvf "${LIBLQR_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBLQR_TARBALL%.tar.bz2})" || fail "Unable to change into application source directory"

      ./configure ${LIBLQR_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] liblqr is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
