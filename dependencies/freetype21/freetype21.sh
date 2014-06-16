: ${FREETYPE21_DEPENDENCIES:=zlib libpng libjpeg}
: ${FREETYPE21_PREFIX:="${ROSE_SH_DEPS_PREFIX}/freetype/2.1.10"}
: ${FREETYPE21_CONFIGURE_OPTIONS:=
    --prefix="${FREETYPE21_PREFIX}"
    --libdir="${FREETYPE21_PREFIX}/lib"
  }
: ${FREETYPE21_TARBALL:="freetype-2.1.10.tar.gz"}
: ${FREETYPE21_INSTALLED_FILE:="${FREETYPE21_PREFIX}/include/freetype2/freetype/freetype.h"}

#-------------------------------------------------------------------------------
install_freetype21()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${FREETYPE21_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${FREETYPE21_INSTALLED_FILE}" ]; then
      rm -rf "./freetype21"                           || fail "Unable to remove application workspace"
      mkdir -p "freetype21"                           || fail "Unable to create application workspace"
      cd "freetype21/"                                || fail "Unable to change into the application workspace"

      download_tarball "${FREETYPE21_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${FREETYPE21_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${FREETYPE21_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${FREETYPE21_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] freetype21 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
