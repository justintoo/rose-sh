# C++ interface for zeromq
: ${CPPZMQ_DEPENDENCIES:= zeromq}
: ${CPPZMQ_CMAKE_OPTIONS:=
    -DCMAKE_INSTALL_PREFIX="${ROSE_SH_DEPS_PREFIX}"
    -DZeroMQ_DIR="${ROSE_SH_DEPS_PREFIX}"
  }
: ${CPPZMQ_TARBALL:="cppzmq-v4.2.1.tar.gz"}
: ${CPPZMQ_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/zmq.hpp"}

#-------------------------------------------------------------------------------
install_cppzmq()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${CPPZMQ_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${CPPZMQ_INSTALLED_FILE}" ]; then
      rm -rf "./cppzmq"                           || fail "Unable to remove old application workspace"
      mkdir -p "cppzmq"                           || fail "Unable to create application workspace"
      cd "cppzmq/"                                || fail "Unable to change into the application workspace"

      download_tarball "${CPPZMQ_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${CPPZMQ_TARBALL}"                || fail "Unable to unpack application tarball"
      cd cppzmq-4.2.1                             || fail "Unable to change into application source directory"
      mkdir build
      cd build

      cmake ${CPPZMQ_CMAKE_OPTIONS} ..     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
      cd ..
  else
      info "[SKIP] cppzmq is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
