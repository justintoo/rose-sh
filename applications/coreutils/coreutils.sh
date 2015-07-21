: ${COREUTILS_DEPENDENCIES:=}

# Array required for proper variable expansion. Specifically, to
# maintain quotations.
COREUTILS_DEFAULT_CONFIGURE_OPTIONS=()
: ${COREUTILS_CONFIGURE_OPTIONS:=${COREUTILS_DEFAULT_CONFIGURE_OPTIONS[@]}}

#-------------------------------------------------------------------------------
download_coreutils()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_coreutils()
#-------------------------------------------------------------------------------
{
  install_deps ${COREUTILS_DEPENDENCIES} || exit 1
}

#-------------------------------------------------------------------------------
patch_coreutils()
#-------------------------------------------------------------------------------
{
  info "Patching"
}

#-------------------------------------------------------------------------------
configure_coreutils__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  set -x
      CC="${ROSE_CC}" \
        ./configure \
          "${COREUTILS_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_coreutils__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  set -x
      ./configure \
          "${COREUTILS_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_coreutils()
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
