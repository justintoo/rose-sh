: ${LIBFUSE_DEPENDENCIES:=gettext libtool}
: ${LIBFUSE_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_PREFIX}/lib"
  }
: ${LIBFUSE_TARBALL:="libfuse-2.12.tar.gz"}
: ${LIBFUSE_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/libfuse.h"}

#-------------------------------------------------------------------------------
install_libfuse()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBFUSE_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBFUSE_INSTALLED_FILE}" ]; then
      rm -rf "./libfuse"                           || fail "Unable to create application workspace"
      mkdir -p "libfuse"                           || fail "Unable to create application workspace"
      cd "libfuse/"                                || fail "Unable to change into the application workspace"

# TODO:
#      download_tarball "${LIBFUSE_TARBALL}"        || fail "Unable to download application tarball"
git clone --branch fuse_2_8_bugfix https://github.com/libfuse/libfuse.git
cd libfuse/

      # requires AM_ICONV from gettext
      # requires AC_PROG_LIBTOOL from libtool
      ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal" \
         ./makeconf.sh
#      tar xzvf "${LIBFUSE_TARBALL}"                || fail "Unable to unpack application tarball"
#      cd "$(basename ${LIBFUSE_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBFUSE_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libfuse is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
