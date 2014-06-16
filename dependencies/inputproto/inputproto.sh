# Homepage: http://cgit.freedesktop.org/xorg/proto/inputproto/

: ${INPUTPROTO_DEPENDENCIES:=xorg_util_macros}
: ${INPUTPROTO_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${INPUTPROTO_TARBALL:="inputproto-2.3.1.tar.gz"}
: ${INPUTPROTO_INSTALLED_INPUTPROTO:="${ROSE_SH_DEPS_PREFIX}/bin/inputproto"}

#-------------------------------------------------------------------------------
install_inputproto()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${INPUTPROTO_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${INPUTPROTO_INSTALLED_INPUTPROTO}" ]; then
      rm -rf "./inputproto"                           || fail "Unable to remove old application workspace"
      mkdir -p "inputproto"                           || fail "Unable to create application workspace"
      cd "inputproto/"                                || fail "Unable to change into the application workspace"

      download_tarball "${INPUTPROTO_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${INPUTPROTO_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${INPUTPROTO_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ACLOCAL_PATH}" \
          ./autogen.sh                                          || fail "Unable to bootstrap application"
      ./configure ${INPUTPROTO_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] inputproto is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
