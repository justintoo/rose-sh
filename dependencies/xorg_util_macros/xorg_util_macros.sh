# http://cgit.freedesktop.org/xorg/util/macros

: ${XORG_UTIL_MACROS_DEPENDENCIES:=}
: ${XORG_UTIL_MACROS_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${XORG_UTIL_MACROS_TARBALL:="util-macros-1.18.0.tar.gz"}
: ${XORG_UTIL_MACROS_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/share/pkgconfig/xorg-macros.pc"}

#-------------------------------------------------------------------------------
install_xorg_util_macros()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${XORG_UTIL_MACROS_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${XORG_UTIL_MACROS_INSTALLED_FILE}" ]; then
      rm -rf "./xorg_util_macros"                           || fail "Unable to remove application workspace"
      mkdir -p "xorg_util_macros"                           || fail "Unable to create application workspace"
      cd "xorg_util_macros/"                                || fail "Unable to change into the application workspace"

      download_tarball "${XORG_UTIL_MACROS_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${XORG_UTIL_MACROS_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${XORG_UTIL_MACROS_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./autogen.sh                                          || fail "Unable to bootstrap application"
      ./configure ${XORG_UTIL_MACROS_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] xorg_util_macros is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
