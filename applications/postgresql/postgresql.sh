: ${POSTGRESQL_DEPENDENCIES:=zlib openssl libxml2 libxslt flex openldap}
: ${POSTGRESQL_CONFIGURE_OPTIONS:=
    --with-pgport=8432
    --with-libraries="${ROSE_SH_DEPS_PREFIX}/lib"
    --with-includes="${ROSE_SH_DEPS_PREFIX}/include"
    --with-openssl
    --with-libxml
    --with-libxslt
    --without-selinux
    --with-readline
    --without-tcl
    --without-perl
    --without-python
    --without-gssapi
    --without-pam
    --without-krb5
    --with-ldap
    --without-bonjour
    --with-zlib
  }

#-------------------------------------------------------------------------------
download_postgresql()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_postgresql()
#-------------------------------------------------------------------------------
{
  install_deps ${POSTGRESQL_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_postgresql()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_postgresql__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${POSTGRESQL_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_postgresql__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${CC}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${POSTGRESQL_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_postgresql()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make CC="${ROSE_CC}" -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
