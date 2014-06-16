# TODO: Pontetec options
#: ${FONTCONFIG_DEPENDENCIES:=zlib freetype expat docbook_utils}
: ${FONTCONFIG_DEPENDENCIES:=zlib freetype25 expat}
# TODO: Disabling docsdir which requires docbook2pdf
: ${FONTCONFIG_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --disable-docs
  }
: ${FONTCONFIG_TARBALL:="fontconfig-2.10.95.tar.gz"}
: ${FONTCONFIG_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/fontconfig/fontconfig.h"}

#-------------------------------------------------------------------------------
install_fontconfig()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${FONTCONFIG_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${FONTCONFIG_INSTALLED_FILE}" ]; then
      rm -rf "./fontconfig"  || fail "Unable to remove old application workspace"
      mkdir -p "fontconfig"  || fail "Unable to create application workspace"
      cd "fontconfig/"       || fail "Unable to change into the application workspace"

      download_tarball "${FONTCONFIG_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${FONTCONFIG_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${FONTCONFIG_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      PKG_CONFIG_PATH="${FREETYPE21_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}" \
          ./configure ${FONTCONFIG_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] fontconfig is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
