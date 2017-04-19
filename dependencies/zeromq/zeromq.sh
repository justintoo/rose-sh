#Not a real release canidate.  I had to use whatever was in master on 03/03/2017
#because the previous release didn't include the cmake configuration file
: ${ZEROMQ_DEPENDENCIES:=}
: ${ZEROMQ_CMAKE_OPTIONS:=
    -DCMAKE_INSTALL_PREFIX="${ROSE_SH_DEPS_PREFIX}"
  }
: ${ZEROMQ_TARBALL:="zeromq-4.2.3-rc1.tar.gz"}
: ${ZEROMQ_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/zeromq.h"}

#-------------------------------------------------------------------------------
install_zeromq()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${ZEROMQ_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ZEROMQ_INSTALLED_FILE}" ]; then
      rm -rf "./zeromq"                           || fail "Unable to remove old application workspace"
      mkdir -p "zeromq"                           || fail "Unable to create application workspace"
      cd "zeromq/"                                || fail "Unable to change into the application workspace"

      download_tarball "${ZEROMQ_TARBALL}"        || fail "Unable to download application tarball"
      tar zxf "${ZEROMQ_TARBALL}"                 || fail "Unable to unpack application tarball"
      cd "$(basename ${ZEROMQ_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"
      mkdir build
      cd build

      cmake ${ZEROMQ_CMAKE_OPTIONS} ..     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
      cd ..
  else
      info "[SKIP] zeromq is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
