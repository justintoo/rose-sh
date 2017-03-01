: ${NASM_DEPENDENCIES:=}
: ${NASM_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_PREFIX}/lib"
  }
: ${NASM_TARBALL:="nasm-2.12.tar.gz"}
: ${NASM_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/bin/nasm"}

#-------------------------------------------------------------------------------
install_nasm()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${NASM_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${NASM_INSTALLED_FILE}" ]; then
      rm -rf "./nasm"                           || fail "Unable to create application workspace"
      mkdir -p "nasm"                           || fail "Unable to create application workspace"
      cd "nasm/"                                || fail "Unable to change into the application workspace"

# TODO:
#      download_tarball "${NASM_TARBALL}"        || fail "Unable to download application tarball"
wget http://www.nasm.us/pub/nasm/releasebuilds/2.12/${NASM_TARBALL}
      tar xzvf "${NASM_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${NASM_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${NASM_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] nasm is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
