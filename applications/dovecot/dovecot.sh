: ${DOVECOT_DEPENDENCIES:=zlib openldap}

# Array required for proper variable expansion. Specifically, to
# maintain quotations.
DOVECOT_CONFIGURE_OPTIONS_DEFAULT=(
    --with-notify=none
    --without-nss
    --with-shadow
    --without-pam
    --without-bsdauth
    --without-gssapi
    --with-ldap=yes
    --with-sqlite
    --without-pgsql
    --without-mysql
    --without-lucene
    --without-stemmer
    --without-solr
    --with-zlib
    --with-bzlib
    --without-libcap
    --with-ssl=openssl
    --without-libwrap)
: ${DOVECOT_CONFIGURE_OPTIONS:=${DOVECOT_CONFIGURE_OPTIONS_DEFAULT[@]}}

#-------------------------------------------------------------------------------
download_dovecot()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_dovecot()
#-------------------------------------------------------------------------------
{
  install_deps ${DOVECOT_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_dovecot()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_dovecot__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS" \
      LDFLAGS="$LDFLAGS" \
          CC="${ROSE_CC} -rose:markGeneratedFiles" \
              ./configure \
                  --prefix="$(pwd)/install_tree"      \
                  --with-ssldir="$(pwd)/install/ssl"  \
                  "${DOVECOT_CONFIGURE_OPTIONS[@]}"   \
                  || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_dovecot__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS" \
      LDFLAGS="$LDFLAGS" \
          CC="${CC}" \
              ./configure \
                  --prefix="$(pwd)/install_tree"      \
                  --with-ssldir="$(pwd)/install/ssl"  \
                  "${DOVECOT_CONFIGURE_OPTIONS[@]}"   \
                  || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_dovecot()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}         || exit 1
      make -j${parallelism} install || exit 1
  set +x
}
