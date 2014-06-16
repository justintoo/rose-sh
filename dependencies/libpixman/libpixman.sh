: ${LIBPIXMAN_DEPENDENCIES:=libpng}
: ${LIBPIXMAN_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-libpng
  }
: ${LIBPIXMAN_TARBALL:="pixman-0.30.2.tar.gz"}
: ${LIBPIXMAN_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/pixman-1/pixman.h"}

#-------------------------------------------------------------------------------
install_libpixman()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBPIXMAN_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBPIXMAN_INSTALLED_FILE}" ]; then
      rm -rf "./libpixman"  || fail "Unable to remove old application workspace"
      mkdir -p "libpixman"  || fail "Unable to create application workspace"
      cd "libpixman/"       || fail "Unable to change into the application workspace"

      download_tarball "${LIBPIXMAN_TARBALL}"       || fail "Unable to download application tarball"
      tar xzvf "${LIBPIXMAN_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBPIXMAN_TARBALL%.tar.gz})" || fail "Unable to change into application source directory"

      ./configure ${LIBPIXMAN_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] libpixman is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
