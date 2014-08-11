: ${LIBKSBA_DEPENDENCIES:=libgpg_error}
: ${LIBKSBA_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${LIBKSBA_TARBALL:="libksba-1.3.0.tar.bz2"}
: ${LIBKSBA_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/ksba.h"}

#-------------------------------------------------------------------------------
install_libksba()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBKSBA_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBKSBA_INSTALLED_FILE}" ]; then
      rm -rf "./libksba"                           || fail "Unable to create application workspace"
      mkdir -p "libksba"                           || fail "Unable to create application workspace"
      cd "libksba/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBKSBA_TARBALL}"        || fail "Unable to download application tarball"
      tar xjvf "${LIBKSBA_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBKSBA_TARBALL%.tar.bz2})" || fail "Unable to change into application source directory"

      ./configure ${LIBKSBA_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libksba is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
