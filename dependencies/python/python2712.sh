: ${PYTHON2712_DEPENDENCIES:=}
: ${PYTHON2712_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${PYTHON2712_TARBALL:="Python-2.7.12.tgz"}
: ${PYTHON2712_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/pyconfig.h"}

#-------------------------------------------------------------------------------
install_python2712()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${PYTHON2712_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${PYTHON2712_INSTALLED_FILE}" ]; then
      rm -rf "./python2712"                           || fail "Unable to remove old application workspace"
      mkdir -p "python2712"                           || fail "Unable to create application workspace"
      cd "python2712/"                                || fail "Unable to change into the application workspace"

      TARBALL_MIRROR_URLS="http://www.python.org/ftp/python/2.7.12"

      download_tarball "${PYTHON2712_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${PYTHON2712_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${PYTHON2712_TARBALL%.tgz})"  || fail "Unable to change into application source directory"

      ./configure ${PYTHON2712_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] python2712 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
