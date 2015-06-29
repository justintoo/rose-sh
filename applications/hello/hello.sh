: ${HELLO_DEPENDENCIES:=help2man}

# Array required for proper variable expansion. Specifically, to
# maintain quotations.
HELLO_DEFAULT_CONFIGURE_OPTIONS=()
: ${HELLO_CONFIGURE_OPTIONS:=${HELLO_DEFAULT_CONFIGURE_OPTIONS[@]}}

#-------------------------------------------------------------------------------
download_hello()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_hello()
#-------------------------------------------------------------------------------
{
  install_deps ${HELLO_DEPENDENCIES} || exit 1
}

#-------------------------------------------------------------------------------
patch_hello()
#-------------------------------------------------------------------------------
{
  info "Patching"
}

#-------------------------------------------------------------------------------
configure_hello__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  set -x
      CC="${ROSE_CC}" \
        ./configure \
          "${HELLO_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_hello__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  set -x
      ./configure \
          "${HELLO_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_hello()
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
