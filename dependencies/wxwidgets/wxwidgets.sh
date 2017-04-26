: ${WXWIDGETS_DEPENDENCIES:=gtk324}
: ${WXWIDGETS_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }

# https://github.com/wxWidgets/wxWidgets/releases/download/v3.0.2/wxWidgets-3.0.2.tar.bz2
: ${WXWIDGETS_TARBALL:="wxWidgets-3.0.2.tar.bz2"}
: ${WXWIDGETS_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/wxh.h"}

#-------------------------------------------------------------------------------
install_wxwidgets()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${WXWIDGETS_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${WXWIDGETS_INSTALLED_FILE}" ]; then
      rm -rf "./wxwidgets"                           || fail "Unable to remove old application workspace"
      mkdir -p "wxwidgets"                           || fail "Unable to create application workspace"
      cd "wxwidgets/"                                || fail "Unable to change into the application workspace"

      download_tarball "${WXWIDGETS_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${WXWIDGETS_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${WXWIDGETS_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${WXWIDGETS_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] wxwidgets is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
