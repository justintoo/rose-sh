: ${EXPAT_DEPENDENCIES:=}
: ${EXPAT_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${EXPAT_TARBALL:="expat-2.1.0.tar.gz"}
: ${EXPAT_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/expat.h"}

#-------------------------------------------------------------------------------
install_expat()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${EXPAT_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${EXPAT_INSTALLED_FILE}" ]; then
      rm -rf "./expat"                           || fail "Unable to create application workspace"
      mkdir -p "expat"                           || fail "Unable to create application workspace"
      cd "expat/"                                || fail "Unable to change into the application workspace"

      download_tarball "${EXPAT_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${EXPAT_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${EXPAT_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${EXPAT_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] expat is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
