# Homepage: http://cgit.freedesktop.org/xorg/xserver

: ${XORG_SERVER_DEPENDENCIES:=xorg_util_macros}
: ${XORG_SERVER_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-static
  }
: ${XORG_SERVER_TARBALL:="xorg-server-1.14.7.tar.gz"}
: ${XORG_SERVER_INSTALLED_XORG_SERVER:="${ROSE_SH_DEPS_PREFIX}/bin/xorg_server"}

#-------------------------------------------------------------------------------
install_xorg_server()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${XORG_SERVER_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${XORG_SERVER_INSTALLED_XORG_SERVER}" ]; then
      rm -rf "./xorg_server"                           || fail "Unable to remove old application workspace"
      mkdir -p "xorg_server"                           || fail "Unable to create application workspace"
      cd "xorg_server/"                                || fail "Unable to change into the application workspace"

      download_tarball "${XORG_SERVER_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${XORG_SERVER_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${XORG_SERVER_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ACLOCAL_PATH}" \
          ./autogen.sh                                          || fail "Unable to bootstrap application"
      ./configure ${XORG_SERVER_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] xorg_server is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
