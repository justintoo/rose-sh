: ${TIFF_DEPENDENCIES:=zlib libjpeg}
: ${TIFF_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --without-x
    --disable-jbig
  }
: ${TIFF_TARBALL:="tiff-3.9.7.tar.gz"}
: ${TIFF_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/tiff.h"}

#-------------------------------------------------------------------------------
install_tiff()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${TIFF_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${TIFF_INSTALLED_FILE}" ]; then
      rm -rf "./tiff"                           || fail "Unable to create application workspace"
      mkdir -p "tiff"                           || fail "Unable to create application workspace"
      cd "tiff/"                                || fail "Unable to change into the application workspace"

      download_tarball "${TIFF_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${TIFF_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${TIFF_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${TIFF_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] tiff is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
