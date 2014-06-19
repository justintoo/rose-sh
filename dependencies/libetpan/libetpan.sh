: ${LIBETPAN_DEPENDENCIES:=openssl zlib cyrus_sasl db expat curl}
: ${LIBETPAN_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-openssl="$ROSE_SH_DEPS_PREFIX"
    --with-sasl="$ROSE_SH_DEPS_PREFIX"
    --with-curl="$ROSE_SH_DEPS_PREFIX"
    --with-expat="$ROSE_SH_DEPS_PREFIX"
    --with-zlib
  }
: ${LIBETPAN_TARBALL:="libetpan-1.2.tar.bz2"}
: ${LIBETPAN_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/libetpan.h"}

#-------------------------------------------------------------------------------
install_libetpan()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBETPAN_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBETPAN_INSTALLED_FILE}" ]; then
      rm -rf "./libetpan"                           || fail "Unable to create application workspace"
      mkdir -p "libetpan"                           || fail "Unable to create application workspace"
      cd "libetpan/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBETPAN_TARBALL}"        || fail "Unable to download application tarball"
      tar xjvf "${LIBETPAN_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBETPAN_TARBALL%.tar.bz2})" || fail "Unable to change into application source directory"

      ./configure ${LIBETPAN_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libetpan is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
