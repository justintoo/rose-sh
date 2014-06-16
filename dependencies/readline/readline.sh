: ${READLINE_DEPENDENCIES:=ncurses}
: ${READLINE_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --with-curses
  }
: ${READLINE_TARBALL:="readline-6.2.tar.gz"}
: ${READLINE_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/readline/readline.h"}

#-------------------------------------------------------------------------------
install_readline()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${READLINE_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${READLINE_INSTALLED_FILE}" ]; then
      rm -rf "./readline"                           || fail "Unable to create application workspace"
      mkdir -p "readline"                           || fail "Unable to create application workspace"
      cd "readline/"                                || fail "Unable to change into the application workspace"

      download_tarball "${READLINE_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${READLINE_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${READLINE_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${READLINE_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] readline is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
