: ${LIBJPEG_DEPENDENCIES:=}
: ${LIBJPEG_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${LIBJPEG_TARBALL:="jpegsrc.v8d.tar.gz"}
: ${LIBJPEG_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/jpeglib.h"}

#-------------------------------------------------------------------------------
install_libjpeg()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBJPEG_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBJPEG_INSTALLED_FILE}" ]; then
      rm -rf "./libjpeg"                           || fail "Unable to create application workspace"
      mkdir -p "libjpeg"                           || fail "Unable to create application workspace"
      cd "libjpeg/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBJPEG_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBJPEG_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "jpeg-8d/"                                || fail "Unable to change into application source directory"

      ./configure ${LIBJPEG_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libjpeg is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
