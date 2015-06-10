: ${APACHE_HTTPD_DEPENDENCIES:=pcre apr apr_util}

# Array required for proper variable expansion. Specifically, to
# maintain quotations.
APACHE_HTTPD_DEFAULT_CONFIGURE_OPTIONS=(
    --with-pcre=\"${ROSE_SH_DEPS_PREFIX}\"
    --with-apr=\"${ROSE_SH_DEPS_PREFIX}\"
    --with-apr-util=\"${ROSE_SH_DEPS_PREFIX}\")
: ${APACHE_HTTPD_CONFIGURE_OPTIONS:=${APACHE_HTTPD_DEFAULT_CONFIGURE_OPTIONS[@]}}

#-------------------------------------------------------------------------------
download_apache_httpd()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_apache_httpd()
#-------------------------------------------------------------------------------
{
  install_deps ${APACHE_HTTPD_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_apache_httpd()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_apache_httpd__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      ./configure \
          --prefix="$(pwd)/2.4.6" \
          "${APACHE_HTTPD_CONFIGURE_OPTIONS[@]}" \
          || exit 1

      export CC="${ROSE_CC} -rose:unparse_in_same_directory_as_input_file"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_apache_httpd__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      ./configure \
          --prefix="$(pwd)/2.4.6" \
          "${APACHE_HTTPD_CONFIGURE_OPTIONS[@]}" \
          || exit 1

      export CC="${CC}"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_apache_httpd()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make V=1 CC="${CC}" -j${parallelism} || exit 1
  set +x
}

