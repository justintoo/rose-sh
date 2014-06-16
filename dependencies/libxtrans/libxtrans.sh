# Homepage: http://cgit.freedesktop.org/xorg/lib/libxtrans/

: ${LIBXTRANS_DEPENDENCIES:=xorg_util_macros}
: ${LIBXTRANS_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-static
  }
: ${LIBXTRANS_TARBALL:="xtrans-1.3.4.tar.gz"}
: ${LIBXTRANS_INSTALLED_LIBXTRANS:="${ROSE_SH_DEPS_PREFIX}/bin/libxtrans"}

#-------------------------------------------------------------------------------
install_libxtrans()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBXTRANS_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBXTRANS_INSTALLED_LIBXTRANS}" ]; then
      rm -rf "./libxtrans"                           || fail "Unable to remove old application workspace"
      mkdir -p "libxtrans"                           || fail "Unable to create application workspace"
      cd "libxtrans/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBXTRANS_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBXTRANS_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBXTRANS_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ACLOCAL_PATH}" \
          ./autogen.sh                                          || fail "Unable to bootstrap application"
      ./configure ${LIBXTRANS_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libxtrans is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
