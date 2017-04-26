# http://cgit.freedesktop.org/xorg/util/macros
# https://www.x.org/releases/individual/lib/

: ${XORG_LIBXEXT_DEPENDENCIES:=}
: ${XORG_LIBXEXT_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
# https://www.x.org/releases/individual/lib/libXext-1.3.3.tar.gz
: ${XORG_LIBXEXT_TARBALL:="libXext-1.3.3.tar.gz"}
: ${XORG_LIBXEXT_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/lib/pkgconfig/xext.pc"}

#-------------------------------------------------------------------------------
install_xorg_libxext()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${XORG_LIBXEXT_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${XORG_LIBXEXT_INSTALLED_FILE}" ]; then
      rm -rf "./xorg_libxext"                           || fail "Unable to remove application workspace"
      mkdir -p "xorg_libxext"                           || fail "Unable to create application workspace"
      cd "xorg_libxext/"                                || fail "Unable to change into the application workspace"

      download_tarball "${XORG_LIBXEXT_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${XORG_LIBXEXT_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${XORG_LIBXEXT_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${XORG_LIBXEXT_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] xorg_libxext is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
