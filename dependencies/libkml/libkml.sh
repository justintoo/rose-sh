# The libkml 1.3.0 release, slightly modified to get zlib 1.2.11 instead of 1.2.8
# I don't know why I have to define both CMAKE_INSTALL_PREFIX and INSTALL_DIR
: ${LIBKML_DEPENDENCIES:=}
: ${LIBKML_CMAKE_OPTIONS:=
    -DCMAKE_INSTALL_PREFIX="${ROSE_SH_DEPS_PREFIX}"
    -DINSTALL_DIR="${ROSE_SH_DEPS_PREFIX}"
  }
: ${LIBKML_TARBALL:="libkml-1.3.0_rose-v2.tar.gz"}
: ${LIBKML_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/kml/engine.h"}

#-------------------------------------------------------------------------------
install_libkml()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBKML_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBKML_INSTALLED_FILE}" ]; then
      rm -rf "./libkml"                           || fail "Unable to remove old application workspace"
      mkdir -p "libkml"                           || fail "Unable to create application workspace"
      cd "libkml/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBKML_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBKML_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBKML_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"
      mkdir build
      cd build
      
      cmake ${LIBKML_CMAKE_OPTIONS} ..        || fail "Unable to configure application"

      make -j${parallelism}                       || fail "An error occurred during application compilation"
      make -j${parallelism} install               || fail "An error occurred during application installation"
      cd ..
  else
      info "[SKIP] libkml is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
