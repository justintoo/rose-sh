: ${LIBASSUAN_DEPENDENCIES:=libgpg_error}
: ${LIBASSUAN_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${LIBASSUAN_TARBALL:="libassuan-2.1.1.tar.bz2"}
: ${LIBASSUAN_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/assuan.h"}

#-------------------------------------------------------------------------------
install_libassuan()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBASSUAN_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBASSUAN_INSTALLED_FILE}" ]; then
      rm -rf "./libassuan"                           || fail "Unable to create application workspace"
      mkdir -p "libassuan"                           || fail "Unable to create application workspace"
      cd "libassuan/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBASSUAN_TARBALL}"         || fail "Unable to download application tarball"
      tar xjvf "${LIBASSUAN_TARBALL}"                 || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBASSUAN_TARBALL%.tar.bz2})"  || fail "Unable to change into application source directory"

      ./configure ${LIBASSUAN_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      # Cannot be built in parallel
      # http://forums.gentoo.org/viewtopic-t-232109-start-0-postdays-0-postorder-asc-highlight-.html?sid=363227bed20da6c794a9a9f62e06727f
      parallelism=1

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libassuan is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
