: ${FREETYPE25_DEPENDENCIES:=zlib libpng libjpeg}
: ${FREETYPE25_PREFIX:="${ROSE_SH_DEPS_PREFIX}/freetype/2.5.0"}
: ${FREETYPE25_CONFIGURE_OPTIONS:=
    --prefix="${FREETYPE25_PREFIX}"
    --libdir="${FREETYPE25_PREFIX}/lib"
  }
: ${FREETYPE25_TARBALL:="freetype-2.5.0.tar.gz"}
: ${FREETYPE25_INSTALLED_FILE:="${FREETYPE25_PREFIX}/include/freetype2/freetype/freetype.h"}

#-------------------------------------------------------------------------------
install_freetype25()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${FREETYPE25_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${FREETYPE25_INSTALLED_FILE}" ]; then
      rm -rf "./freetype25"  || fail "Unable to remove old application workspace"
      mkdir -p "freetype25"  || fail "Unable to create application workspace"
      cd "freetype25/"       || fail "Unable to change into the application workspace"

      download_tarball "${FREETYPE25_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${FREETYPE25_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${FREETYPE25_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${FREETYPE25_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"

# TOO1 (2/24/2014): WARNING: Internal header files are no longer installed (in newer versions of freetype?):
#
#                   Excerpt from FREETYPE25/builds/unix/install.mk:
#
#                        Unix installation and deinstallation targets.
#
#                        Note that we no longer install internal headers, and we remove any
#                        `internal' subdirectory found in `$(includedir)/freetype2/freetype'.
#
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] freetype25 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
