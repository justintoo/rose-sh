: ${POSTGRES_DEPENDENCIES:=zlib openssl libxml2 libxslt}
: ${POSTGRES_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-libraries="${ROSE_SH_DEPS_LIBDIR}"
    --with-includes="${ROSE_SH_DEPS_PREFIX}/include"
    --with-openssl
    --with-libxml
    --with-libxslt
  }
: ${POSTGRES_TARBALL:="postgresql-9.2.4.tar.bz2"}
: ${POSTGRES_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/postgresql/server/postgres.h"}

#-------------------------------------------------------------------------------
install_postgres()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${POSTGRES_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${POSTGRES_INSTALLED_FILE}" ]; then
      rm -rf "./postgres"  || fail "Unable to remove old application workspace"
      mkdir -p "postgres"  || fail "Unable to create application workspace"
      cd "postgres/"       || fail "Unable to change into the application workspace"

      download_tarball "${POSTGRES_TARBALL}"        || fail "Unable to download application tarball"
      tar xjvf "${POSTGRES_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${POSTGRES_TARBALL%.tar.bz2})" || fail "Unable to change into application source directory"

      LDFLAGS="$LDFLAGS"    \
      CPPFLAGS="$CPPFLAGS"  \
      CFLAGS="$CFLAGS"      \
          ./configure ${POSTGRES_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                             || fail "An error occurred during application compilation"
      make -j${parallelism} -C src/bin install          || fail "An error occurred during application installation"
      make -j${parallelism} -C src/include install      || fail "An error occurred during application installation"
      make -j${parallelism} -C src/interfaces install   || fail "An error occurred during application installation"
      make -j${parallelism} -C doc install              || fail "An error occurred during application installation"
  else
      info "[SKIP] postgres is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
