: ${HARFBUZZ_DEPENDENCIES:=freetype25}
: ${HARFBUZZ_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${HARFBUZZ_TARBALL:="harfbuzz-0.9.26.tar.bz2"}
: ${HARFBUZZ_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/harfbuzz/hb.h"}

#-------------------------------------------------------------------------------
install_harfbuzz()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${HARFBUZZ_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${HARFBUZZ_INSTALLED_FILE}" ]; then
      rm -rf "./harfbuzz"                           || fail "Unable to remove application workspace"
      mkdir -p "harfbuzz"                           || fail "Unable to create application workspace"
      cd "harfbuzz/"                                || fail "Unable to change into the application workspace"

      download_tarball "${HARFBUZZ_TARBALL}"        || fail "Unable to download application tarball"
      tar xjvf "${HARFBUZZ_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${HARFBUZZ_TARBALL%.tar.bz2})" || fail "Unable to change into application source directory"

      PKG_CONFIG_PATH="${FREETYPE25_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}" \
          ./configure ${HARFBUZZ_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] harfbuzz is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
