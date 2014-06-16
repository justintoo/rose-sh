# Homepage: http://cgit.freedesktop.org/xorg/xserver

: ${LIBXKBFILE_DEPENDENCIES:=xorg_util_macros}
: ${LIBXKBFILE_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-static
  }
: ${LIBXKBFILE_TARBALL:="libxkbfile-1.0.8.tar.gz"}
: ${LIBXKBFILE_INSTALLED_LIBXKBFILE:="${ROSE_SH_DEPS_PREFIX}/bin/libxkbfile"}

#-------------------------------------------------------------------------------
install_libxkbfile()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBXKBFILE_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBXKBFILE_INSTALLED_LIBXKBFILE}" ]; then
      rm -rf "./libxkbfile"                           || fail "Unable to remove old application workspace"
      mkdir -p "libxkbfile"                           || fail "Unable to create application workspace"
      cd "libxkbfile/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBXKBFILE_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBXKBFILE_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBXKBFILE_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ACLOCAL_PATH}" \
          ./autogen.sh                                          || fail "Unable to bootstrap application"
      ./configure ${LIBXKBFILE_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libxkbfile is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
