: ${BZIP2_DEPENDENCIES:=}
: ${BZIP2_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${BZIP2_TARBALL:="bzip2-1.0.6.tar.gz"}
: ${BZIP2_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/bzlib.h"}

#-------------------------------------------------------------------------------
install_bzip2()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${BZIP2_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${BZIP2_INSTALLED_FILE}" ]; then
      rm -rf "./bzip2"                            || fail "Unable to create application workspace"
      mkdir -p "bzip2"                            || fail "Unable to create application workspace"
      cd "bzip2/"                                 || fail "Unable to change into the application workspace"

      download_tarball "${BZIP2_TARBALL}"         || fail "Unable to download application tarball"
      tar xzvf "${BZIP2_TARBALL}"                 || fail "Unable to unpack application tarball"
      cd "$(basename ${BZIP2_TARBALL%.tar.gz})"   || fail "Unable to change into application source directory"

      make install \
          -j${parallelism} \
          PREFIX="${ROSE_SH_DEPS_PREFIX}" \
          LDFLAGS="$LDFLAGS" \
          CPPFLAGS="$CFLAGS -fPIC" \
          LIBDIR="lib64"                          || fail "An error occurred during application installation"

  else
      info "[SKIP] bzip2 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
