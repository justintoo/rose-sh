: ${PIXMAN_DEPENDENCIES:=}
: ${PIXMAN_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${PIXMAN_TARBALL:="pixman_0.32.6.orig.tar.gz"}
: ${PIXMAN_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/pixman-1/pixman.h"}

#-------------------------------------------------------------------------------
install_pixman()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${PIXMAN_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${PIXMAN_INSTALLED_FILE}" ]; then
      rm -rf "./pixman"                           || fail "Unable to remove old application workspace"
      mkdir -p "pixman"                           || fail "Unable to create application workspace"
      cd "pixman/"                                || fail "Unable to change into the application workspace"

      download_tarball "${PIXMAN_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${PIXMAN_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(echo $(basename ${PIXMAN_TARBALL%.orig.tar.gz}) | sed 's/_/-/')"  || fail "Unable to change into application source directory"

      ./configure ${PIXMAN_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] pixman is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
