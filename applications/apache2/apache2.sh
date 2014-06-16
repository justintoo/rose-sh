: ${APACHE2_DEPENDENCIES:=zlib openssl pcre libxml2 apr apr_util}

# Array required for proper variable expansion. Specifically, to
# maintain quotations.
APACHE2_DEFAULT_CONFIGURE_OPTIONS=(
    --with-port=8888
    --with-sslport=8887
    --with-program-name=apache2
    --enable-so
    --disable-suexec
    --disable-lua
    --disable-luajit
    --enable-auth-digest
    --enable-basic-digest
    --with-ssl=\"${ROSE_SH_DEPS_PREFIX}\"
    --with-libxml2=\"${ROSE_SH_DEPS_PREFIX}\"
    --with-z=\"${ROSE_SH_DEPS_PREFIX}\"
    --with-pcre=\"${ROSE_SH_DEPS_PREFIX}\"
    --with-apr=\"${ROSE_SH_DEPS_PREFIX}\"
    --with-apr-util=\"${ROSE_SH_DEPS_PREFIX}\"
    --enable-pie
    --enable-mpms-shared=all
    --enable-mods-shared=\"all cgi\"
    --enable-mods-static=\"unixd logio watchdog version\")
: ${APACHE2_CONFIGURE_OPTIONS:=${APACHE2_DEFAULT_CONFIGURE_OPTIONS[@]}}

#-------------------------------------------------------------------------------
download_apache2()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_apache2()
#-------------------------------------------------------------------------------
{
  install_deps ${APACHE2_DEPENDENCIES} || exit 1
}

#-------------------------------------------------------------------------------
patch_apache2()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_apache2__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  set -x
      CC="${ROSE_CC}" \
      \
          CPPFLAGS="$SS_CPPFLAGS" \
          CFLAGS="$SS_CFLAGS"     \
          LDFLAGS="$SS_LDFLAGS"   \
      \
          ./configure \
              --prefix="$(pwd)/install_tree"    \
              "${APACHE2_CONFIGURE_OPTIONS[@]}" \
              || exit 1

  set +x
}

#-------------------------------------------------------------------------------
configure_apache2__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  set -x
      CC="${CC}" \
      \
          CPPFLAGS="$SS_CPPFLAGS" \
          CFLAGS="$SS_CFLAGS"     \
          LDFLAGS="$SS_LDFLAGS"   \
      \
          ./configure \
              --prefix="$(pwd)/install_tree"    \
              "${APACHE2_CONFIGURE_OPTIONS[@]}" \
              || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_apache2()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
