: ${FLEX_DEPENDENCIES:=}
: ${FLEX_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
  }
: ${FLEX_TARBALL:="flex-2.5.4a.tar.gz"}
: ${FLEX_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/FlexLexer.h"}

#-------------------------------------------------------------------------------
install_flex()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${FLEX_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${FLEX_INSTALLED_FILE}" ]; then
      rm -rf "./flex"                           || fail "Unable to remove application workspace"
      mkdir -p "flex"                           || fail "Unable to create application workspace"
      cd "flex/"                                || fail "Unable to change into the application workspace"

      download_tarball "${FLEX_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${FLEX_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${FLEX_TARBALL%a.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${FLEX_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] flex is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
