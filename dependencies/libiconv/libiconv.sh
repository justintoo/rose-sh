: ${LIBICONV_DEPENDENCIES:=}
: ${LIBICONV_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${LIBICONV_TARBALL:="libiconv-1.14.tar.gz"}
: ${LIBICONV_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/iconv.h"}

#-------------------------------------------------------------------------------
install_libiconv()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBICONV_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBICONV_INSTALLED_FILE}" ]; then
      rm -rf "./libiconv"  || fail "Unable to remove old application workspace"
      mkdir -p "libiconv"  || fail "Unable to create application workspace"
      cd "libiconv/"       || fail "Unable to change into the application workspace"

      download_tarball "${LIBICONV_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBICONV_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBICONV_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      LDFLAGS="$LDFLAGS"    \
      CPPFLAGS="$CPPFLAGS"  \
      CFLAGS="$CFLAGS"      \
          ./configure ${LIBICONV_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}           || fail "An error occurred during application compilation"
      make -j${parallelism} install   || fail "An error occurred during application installation"
  else
      info "[SKIP] libiconv is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
