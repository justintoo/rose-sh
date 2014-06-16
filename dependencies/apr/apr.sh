: ${APR_DEPENDENCIES:=}
: ${APR_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_PREFIX}/lib"
  }
: ${APR_TARBALL:="apr-1.4.8.tar.gz"}
: ${APR_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/apr-1/apr.h"}

#-------------------------------------------------------------------------------
install_apr()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${APR_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${APR_INSTALLED_FILE}" ]; then
      rm -rf "./apr"                           || fail "Unable to create application workspace"
      mkdir -p "apr"                           || fail "Unable to create application workspace"
      cd "apr/"                                || fail "Unable to change into the application workspace"

      download_tarball "${APR_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${APR_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${APR_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${APR_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] apr is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
