: ${NEON_DEPENDENCIES:=zlib openssl libxml2 expat}
: ${NEON_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-shared
    --disable-debug
    --with-libs="${ROSE_SH_DEPS_PREFIX}"
    --with-ssl=openssl
    --without-gssapi
    --with-libxml2
    --with-expat
    --with-zlib
  }
: ${NEON_TARBALL:="neon-0.30.0.tar.gz"}
: ${NEON_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/neon/ne_utils.h"}

#-------------------------------------------------------------------------------
install_neon()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${NEON_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${NEON_INSTALLED_FILE}" ]; then
      rm -rf "./neon"  || fail "Unable to remove old application workspace"
      mkdir -p "neon"  || fail "Unable to create application workspace"
      cd "neon/"       || fail "Unable to change into the application workspace"

      download_tarball "${NEON_TARBALL}"       || fail "Unable to download application tarball"
      tar xzvf "${NEON_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${NEON_TARBALL%.tar.gz})" || fail "Unable to change into application source directory"

      ./configure ${NEON_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] neon is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
