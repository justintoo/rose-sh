: ${LIBXML2_DEPENDENCIES:=zlib readline}
: ${LIBXML2_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-libxml2="$ROSE_SH_DEPS_PREFIX"
    --without-lzma
    --with-readline="$ROSE_SH_DEPS_PREFIX"
    --without-python
  }
: ${LIBXML2_TARBALL:="libxml2-2.9.1.tar.gz"}
: ${LIBXML2_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/libxml2/libxml/xmlschemas.h"}

#-------------------------------------------------------------------------------
install_libxml2()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBXML2_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBXML2_INSTALLED_FILE}" ]; then
      rm -rf "./libxml2"                           || fail "Unable to create application workspace"
      mkdir -p "libxml2"                           || fail "Unable to create application workspace"
      cd "libxml2/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBXML2_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBXML2_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBXML2_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      # TOO1 (3/19/2014): RHEL6: Add CFLAGS/LDFLAGS in order to find gzopen64 in libz (zlib).
      CFLAGS="${CFLAGS}" \
      LDFLAGS="${LDFLAGS}" \
          ./configure ${LIBXML2_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libxml2 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
