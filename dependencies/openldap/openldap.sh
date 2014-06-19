: ${OPENLDAP_DEPENDENCIES:=openssl zlib cyrus_sasl}
: ${OPENLDAP_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_PREFIX}/lib"
    --disable-slapd
    --with-cyrus-sasl
    --with-tls=openssl
  }
: ${OPENLDAP_TARBALL:="openldap-2.4.36.tgz"}
: ${OPENLDAP_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/ldap.h"}

#-------------------------------------------------------------------------------
install_openldap()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${OPENLDAP_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${OPENLDAP_INSTALLED_FILE}" ]; then
      rm -rf "./openldap"                           || fail "Unable to create application workspace"
      mkdir -p "openldap"                           || fail "Unable to create application workspace"
      cd "openldap/"                                || fail "Unable to change into the application workspace"

      download_tarball "${OPENLDAP_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${OPENLDAP_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${OPENLDAP_TARBALL%.tgz})"     || fail "Unable to change into application source directory"

      ./configure ${OPENLDAP_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                         || fail "An error occurred during application compilation"
      make -j${parallelism} install                 || fail "An error occurred during application installation"
  else
      info "[SKIP] openldap is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
