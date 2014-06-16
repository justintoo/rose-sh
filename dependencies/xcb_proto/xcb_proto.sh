: ${XCB_PROTO_DEPENDENCIES:=}
: ${XCB_PROTO_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${XCB_PROTO_TARBALL:="xcb-proto-1.8.tar.gz"}
: ${XCB_PROTO_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/lib/pkgconfig/xcb-proto.pc"}

#-------------------------------------------------------------------------------
install_xcb_proto()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${XCB_PROTO_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${XCB_PROTO_INSTALLED_FILE}" ]; then
      rm -rf "./xcb_proto"  || fail "Unable to remove old application workspace"
      mkdir -p "xcb_proto"  || fail "Unable to create application workspace"
      cd "xcb_proto/"       || fail "Unable to change into the application workspace"

      download_tarball "${XCB_PROTO_TARBALL}"       || fail "Unable to download application tarball"
      tar xzvf "${XCB_PROTO_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${XCB_PROTO_TARBALL%.tar.gz})" || fail "Unable to change into application source directory"

      ./configure ${XCB_PROTO_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] xcb_proto is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
