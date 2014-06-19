: ${CYRUS_SASL_DEPENDENCIES:=gdbm db openssl zlib}
: ${CYRUS_SASL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_PREFIX}/lib"
    --enable-static
    --with-devrandom=/dev/urandom
    --disable-ntlm
    --disable-krb4
    --disable-ldapdb
    --disable-macos-framework
    --with-javabase="$ROSE_SH_DEPS_PREFIX/java/include"
    --with-dbpath="$ROSE_SH_DEPS_PREFIX/etc/sasldb2"
    --with-dblib=berkeley
    --with-bdb-libdir="$ROSE_SH_DEPS_PREFIX/lib"
    --with-bdb-incdir="$ROSE_SH_DEPS_PREFIX/include"
    --with-gdbm="$ROSE_SH_DEPS_PREFIX"
    --with-openssl="$ROSE_SH_DEPS_PREFIX"
    --with-sqlite3="$ROSE_SH_DEPS_PREFIX"
    --with-plugindir="$ROSE_SH_DEPS_PREFIX/lib/sasl2"
    --with-configdir="$ROSE_SH_DEPS_PREFIX/lib/sasl2"
    --disable-gssapi
  }
: ${CYRUS_SASL_TARBALL:="cyrus-sasl-2.1.26.tar.gz"}
: ${CYRUS_SASL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/sasl/sasl.h"}

#-------------------------------------------------------------------------------
install_cyrus_sasl()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${CYRUS_SASL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${CYRUS_SASL_INSTALLED_FILE}" ]; then
      rm -rf "./cyrus_sasl"                           || fail "Unable to create application workspace"
      mkdir -p "cyrus_sasl"                           || fail "Unable to create application workspace"
      cd "cyrus_sasl/"                                || fail "Unable to change into the application workspace"

      download_tarball "${CYRUS_SASL_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${CYRUS_SASL_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${CYRUS_SASL_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${CYRUS_SASL_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                           || fail "An error occurred during application compilation"
      make -j${parallelism} install                   || fail "An error occurred during application installation"
  else
      info "[SKIP] cyrus_sasl is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
