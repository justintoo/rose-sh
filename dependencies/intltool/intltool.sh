: ${INTLTOOL_DEPENDENCIES:=}
: ${INTLTOOL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${INTLTOOL_TARBALL:="intltool-0.50.2.tar.gz"}
: ${INTLTOOL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/share/aclocal/intltool.m4"}

#-------------------------------------------------------------------------------
install_intltool()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${INTLTOOL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${INTLTOOL_INSTALLED_FILE}" ]; then
      rm -rf "./intltool"                           || fail "Unable to remove application workspace"
      mkdir -p "intltool"                           || fail "Unable to create application workspace"
      cd "intltool/"                                || fail "Unable to change into the application workspace"

      download_tarball "${INTLTOOL_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${INTLTOOL_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${INTLTOOL_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${INTLTOOL_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] intltool is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
