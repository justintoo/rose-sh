: ${MYSQL_DEPENDENCIES:=}
: ${MYSQL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${MYSQL_TARBALL:="mysql-5.1.72.tar.gz"}
: ${MYSQL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/mysql/mysql.h"}

#-------------------------------------------------------------------------------
install_mysql()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${MYSQL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${MYSQL_INSTALLED_FILE}" ]; then
      rm -rf "./mysql"                           || fail "Unable to remove application workspace"
      mkdir -p "mysql"                           || fail "Unable to create application workspace"
      cd "mysql/"                                || fail "Unable to change into the application workspace"

      download_tarball "${MYSQL_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${MYSQL_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${MYSQL_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${MYSQL_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] mysql is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
