: ${GZIP_DEPENDENCIES:=}

# Array required for proper variable expansion. Specifically, to
# maintain quotations.
GZIP_DEFAULT_CONFIGURE_OPTIONS=()
: ${GZIP_CONFIGURE_OPTIONS:=${GZIP_DEFAULT_CONFIGURE_OPTIONS[@]}}

#-------------------------------------------------------------------------------
download_gzip()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_gzip()
#-------------------------------------------------------------------------------
{
  install_deps ${GZIP_DEPENDENCIES} || exit 1
}

#-------------------------------------------------------------------------------
patch_gzip()
#-------------------------------------------------------------------------------
{
  info "Patching"
}

#-------------------------------------------------------------------------------
configure_gzip__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  set -x
      autoreconf || exit 1
      CC="${ROSE_CC}" \
        ./configure \
          "${GZIP_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_gzip__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  set -x
      ./configure \
          "${GZIP_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_gzip()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make V=1 -j${parallelism} || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
