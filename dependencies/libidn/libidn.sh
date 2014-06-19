: ${LIBIDN_DEPENDENCIES:=}
: ${LIBIDN_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${LIBIDN_TARBALL:="libidn-1.28.tar.gz"}
: ${LIBIDN_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/idna.h"}

#-------------------------------------------------------------------------------
install_libidn()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBIDN_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBIDN_INSTALLED_FILE}" ]; then
      rm -rf "./libidn"                           || fail "Unable to create application workspace"
      mkdir -p "libidn"                           || fail "Unable to create application workspace"
      cd "libidn/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBIDN_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBIDN_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBIDN_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBIDN_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libidn is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
