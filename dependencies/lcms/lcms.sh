: ${LCMS_DEPENDENCIES:=zlib libjpeg tiff}
: ${LCMS_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-zlib
    --with-jpeg
    --with-tiff
  }
: ${LCMS_TARBALL:="lcms2-2.5.tar.gz"}
: ${LCMS_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/lcms2.h"}

#-------------------------------------------------------------------------------
install_lcms()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LCMS_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LCMS_INSTALLED_FILE}" ]; then
      rm -rf "./lcms"  || fail "Unable to create application workspace"
      mkdir -p "lcms"  || fail "Unable to create application workspace"
      cd "lcms/"       || fail "Unable to change into the application workspace"

      download_tarball "${LCMS_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LCMS_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LCMS_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LCMS_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] lcms is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
