: ${LIBPNG_DEPENDENCIES:=zlib}
: ${LIBPNG_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${LIBPNG_TARBALL:="libpng-1.6.6.tar.gz"}
: ${LIBPNG_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/libpng16/png.h"}

#-------------------------------------------------------------------------------
install_libpng()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBPNG_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBPNG_INSTALLED_FILE}" ]; then
      rm -rf "./libpng"                           || fail "Unable to create application workspace"
      mkdir -p "libpng"                           || fail "Unable to create application workspace"
      cd "libpng/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBPNG_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBPNG_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBPNG_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBPNG_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libpng is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
