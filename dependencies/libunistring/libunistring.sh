: ${LIBUNISTRING_DEPENDENCIES:=}
: ${LIBUNISTRING_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${LIBUNISTRING_TARBALL:="libunistring-0.9.3.tar.gz"}
: ${LIBUNISTRING_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/unistring/version.h"}

#-------------------------------------------------------------------------------
install_libunistring()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBUNISTRING_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBUNISTRING_INSTALLED_FILE}" ]; then
      rm -rf "./libunistring"                           || fail "Unable to create application workspace"
      mkdir -p "libunistring"                           || fail "Unable to create application workspace"
      cd "libunistring/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBUNISTRING_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBUNISTRING_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBUNISTRING_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBUNISTRING_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libunistring is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
