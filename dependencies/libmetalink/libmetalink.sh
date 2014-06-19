: ${LIBMETALINK_DEPENDENCIES:=expat libxml2}
: ${LIBMETALINK_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-libexpat
    --with-libxml2
    --with-xml-prefix="$ROSE_SH_DEPS_PREFIX"
  }
: ${LIBMETALINK_TARBALL:="libmetalink-0.1.2.tar.gz"}
: ${LIBMETALINK_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/metalink/metalink.h"}

#-------------------------------------------------------------------------------
install_libmetalink()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBMETALINK_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBMETALINK_INSTALLED_FILE}" ]; then
      rm -rf "./libmetalink"                           || fail "Unable to create application workspace"
      mkdir -p "libmetalink"                           || fail "Unable to create application workspace"
      cd "libmetalink/"                                || fail "Unable to change into the application workspace"

      download_tarball "${LIBMETALINK_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBMETALINK_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBMETALINK_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${LIBMETALINK_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] libmetalink is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
