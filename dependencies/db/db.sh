: ${DB_DEPENDENCIES:=}
: ${DB_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-compat185
    --enable-cxx
  }
: ${DB_TARBALL:="db-4.8.30.tar.gz"}
: ${DB_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/db.h"}

#-------------------------------------------------------------------------------
install_db()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${DB_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${DB_INSTALLED_FILE}" ]; then
      rm -rf "./db"                           || fail "Unable to create application workspace"
      mkdir "db"                              || fail "Unable to create application workspace"
      cd "db/"                                || fail "Unable to change into the application workspace"

      download_tarball "${DB_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${DB_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${DB_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      cd "build_unix"                         || fail "Unable to change in application build directory"
      ../dist/configure \
          ${DB_CONFIGURE_OPTIONS}             || fail "Unable to configure application"

      make -j${parallelism}                   || fail "An error occurred during application compilation"
      make -j${parallelism} install           || fail "An error occurred during application installation"
  else
      info "[SKIP] db is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
