: ${PTHREAD_STUBS_DEPENDENCIES:=}
: ${PTHREAD_STUBS_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${PTHREAD_STUBS_TARBALL:="pthread-stubs-0.3.tar.gz"}
: ${PTHREAD_STUBS_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/lib/pkgconfig/pthread-stubs.pc"}

#-------------------------------------------------------------------------------
install_pthread_stubs()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${PTHREAD_STUBS_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${PTHREAD_STUBS_INSTALLED_FILE}" ]; then
      rm -rf "./pthread_stubs"                           || fail "Unable to create application workspace"
      mkdir -p "pthread_stubs"                           || fail "Unable to create application workspace"
      cd "pthread_stubs/"                                || fail "Unable to change into the application workspace"

      download_tarball "${PTHREAD_STUBS_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${PTHREAD_STUBS_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${PTHREAD_STUBS_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      # TOO1 (2/7/2014): Autoreconf command extracted from PTHREAD_STUBS/autogen.sh;
      #                  libtool.m4 must be found in the ACLOCAL_PATH.
      ACLOCAL_PATH="${LIBTOOL_HOME}/share/aclocal:${ACLOCAL_PATH}" \
          autoreconf -v --install                        || fail "Unable to bootstrap application"

      ./configure ${PTHREAD_STUBS_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] pthread_stubs is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
