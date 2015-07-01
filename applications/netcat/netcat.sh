: ${NETCAT_DEPENDENCIES:=}

# Array required for proper variable expansion. Specifically, to
# maintain quotations.
NETCAT_DEFAULT_CONFIGURE_OPTIONS=()
: ${NETCAT_CONFIGURE_OPTIONS:=${NETCAT_DEFAULT_CONFIGURE_OPTIONS[@]}}

#-------------------------------------------------------------------------------
download_netcat()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_netcat()
#-------------------------------------------------------------------------------
{
  install_deps ${NETCAT_DEPENDENCIES} || exit 1
}

#-------------------------------------------------------------------------------
patch_netcat()
#-------------------------------------------------------------------------------
{
  info "Patching"
}

#-------------------------------------------------------------------------------
configure_netcat__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  set -x
      CC="${ROSE_CC}" \
        ./configure \
          "${NETCAT_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
configure_netcat__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  set -x
      ./configure \
          "${NETCAT_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  set +x
}

#-------------------------------------------------------------------------------
compile_netcat()
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
