: ${DIFFUTILS_DEPENDENCIES:=}

# Array required for proper variable expansion. Specifically, to
# maintain quotations.
DIFFUTILS_DEFAULT_CONFIGURE_OPTIONS=()
: ${DIFFUTILS_CONFIGURE_OPTIONS:=${DIFFUTILS_DEFAULT_CONFIGURE_OPTIONS[@]}}

#-------------------------------------------------------------------------------
download_diffutils()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_diffutils()
#-------------------------------------------------------------------------------
{
  install_deps ${DIFFUTILS_DEPENDENCIES} || exit 1
}

#-------------------------------------------------------------------------------
patch_diffutils()
#-------------------------------------------------------------------------------
{
  info "Patching"
}

#-------------------------------------------------------------------------------
configure_diffutils__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  set -x
      CC="${ROSE_CC}" \
        ./configure \
          "${DIFFUTILS_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_diffutils__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  set -x
      ./configure \
          "${DIFFUTILS_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_diffutils()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make -j${parallelism} || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
