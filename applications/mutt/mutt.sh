: ${MUTT_DEPENDENCIES:=ncurses}

# Array required for proper variable expansion. Specifically, to
# maintain quotations.
MUTT_DEFAULT_CONFIGURE_OPTIONS=(
    --with-curses=\"${ROSE_SH_DEPS_PREFIX}\")
: ${MUTT_CONFIGURE_OPTIONS:=${MUTT_DEFAULT_CONFIGURE_OPTIONS[@]}}

#-------------------------------------------------------------------------------
download_mutt()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_mutt()
#-------------------------------------------------------------------------------
{
  install_deps ${MUTT_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_mutt()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_mutt__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      export CC="${ROSE_CC}"
      LDFLAGS="-L${ROSE_SH_DEPS_PREFIX}/lib ${LDFLAGS}" \
        ./configure \
            "${MUTT_CONFIGURE_OPTIONS[@]}" \
            || exit 1

  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_mutt__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      export CC="${ROSE_CC}"

      ./configure \
          "${MUTT_CONFIGURE_OPTIONS[@]}" \
          || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_mutt()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism} || exit 1
  set +x
}

