: ${CURL_DEPENDENCIES:=openssl zlib libidn openldap libssh2 libmetalink}
: ${CURL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-ssl="$ROSE_SH_DEPS_PREFIX"
    --with-libssh2="$ROSE_SH_DEPS_PREFIX"
    --with-libidn="$ROSE_SH_DEPS_PREFIX"
    --disable-ntlm-wb
    --with-zlib="$ROSE_SH_DEPS_PREFIX"
    --with-libmetalink="$ROSE_SH_DEPS_PREFIX"
    --without-winssl
    --without-darwinssl
    --without-gnutls
    --without-polarssl
    --without-cyassl
    --without-nss
    --without-axtls
    --without-librtmp
    --without-winidn
  }
: ${CURL_TARBALL:="curl-7.32.0.tar.gz"}
: ${CURL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/curl/curl.h"}

#-------------------------------------------------------------------------------
install_curl()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${CURL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${CURL_INSTALLED_FILE}" ]; then
      rm -rf "./curl"                           || fail "Unable to create application workspace"
      mkdir -p "curl"                           || fail "Unable to create application workspace"
      cd "curl/"                                || fail "Unable to change into the application workspace"

      download_tarball "${CURL_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${CURL_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${CURL_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${CURL_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] curl is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
