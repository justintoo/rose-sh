: ${HELP2MAN_DEPENDENCIES:=}
: ${HELP2MAN_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${HELP2MAN_TARBALL:="help2man-1.47.1.tar.xz"}
: ${HELP2MAN_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/help2man.h"}

#-------------------------------------------------------------------------------
install_help2man()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${HELP2MAN_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${HELP2MAN_INSTALLED_FILE}" ]; then
      rm -rf "./help2man"                           || fail "Unable to remove old application workspace"
      mkdir -p "help2man"                           || fail "Unable to create application workspace"
      cd "help2man/"                                || fail "Unable to change into the application workspace"

      download_tarball "${HELP2MAN_TARBALL}"        || fail "Unable to download application tarball"
      unxz "${HELP2MAN_TARBALL}"                    || fail "Unable to unpack application tarball"
      tar xvf "${HELP2MAN_TARBALL%.xz}"             || fail "Unable to unpack application tarball"
      cd "$(basename ${HELP2MAN_TARBALL%.tar.xz})"  || fail "Unable to change into application source directory"

      ./configure ${HELP2MAN_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] help2man is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
