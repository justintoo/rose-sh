: ${SQLITE3_DEPENDENCIES:=readline}
: ${SQLITE3_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${SQLITE3_TARBALL:="sqlite-autoconf-3080002.tar.gz"}
: ${SQLITE3_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/sqlite3.h"}

#-------------------------------------------------------------------------------
install_sqlite3()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${SQLITE3_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${SQLITE3_INSTALLED_FILE}" ]; then
      rm -rf "./sqlite3"                           || fail "Unable to create application workspace"
      mkdir -p "sqlite3"                           || fail "Unable to create application workspace"
      cd "sqlite3/"                                || fail "Unable to change into the application workspace"

      download_tarball "${SQLITE3_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${SQLITE3_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${SQLITE3_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${SQLITE3_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] sqlite3 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
