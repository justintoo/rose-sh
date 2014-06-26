: ${LIBMICROHTTPD_DEPENDENCIES:=file}
: ${LIBMICROHTTPD_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-libcurl="$ROSE_SH_DEPS_PREFIX"
    --with-openssl="$ROSE_SH_DEPS_PREFIX"
    --with-libgcrypt-prefix="$ROSE_SH_DEPS_PREFIX"
  }
: ${LIBMICROHTTPD_TARBALL:="libmicrohttpd-0.9.27.tar.gz"}
: ${LIBMICROHTTPD_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/microhttpd.h"}

#-------------------------------------------------------------------------------
install_libmicrohttpd()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBMICROHTTPD_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBMICROHTTPD_INSTALLED_FILE}" ]; then
      rm -rf "./libmicrohttpd"                           || fail "Unable to create application workspace"
      mkdir -p "libmicrohttpd"                           || fail "Unable to create application workspace"
      cd "libmicrohttpd/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBMICROHTTPD_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBMICROHTTPD_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBMICROHTTPD_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBMICROHTTPD_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libmicrohttpd is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
