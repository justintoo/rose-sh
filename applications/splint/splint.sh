: ${SPLINT_DEPENDENCIES:=}
: ${SPLINT_CONFIGURE_OPTIONS:=
  }

#-------------------------------------------------------------------------------
download_splint()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_splint()
#-------------------------------------------------------------------------------
{
  install_deps ${SPLINT_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_splint()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_splint__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  # TOO1 (2/24/2014): Manually bootstrap Autotools. This resolves a bug where
  #                   a hardcoded, although generated, call to aclocal-1.6 is
  #                   made on RHEL6, where the system default is aclocal-1.11.
  ${SHELL} ./config/missing --run aclocal   || fail "Failed aclocal"
  ${SHELL} ./config/missing --run autoconf  || fail "Failed autoconf"
  ${SHELL} ./config/missing --run automake --add-missing || fail "Failed automake"
  ${SHELL} ./config/missing --run autoheader || fail "Failed autoheader"

      CC="${ROSE_CC}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${SPLINT_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_splint__gcc()
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
              ${SPLINT_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_splint()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      # TOO1 (2/24/2014): Fails parallel compilation in Phase 1
      parallelism=1
      make -j${parallelism}         || fail "An error occurred during application compilation"
# TOO1 (2/24/2014): Fails in Phase 1
#      make -j${parallelism} install || fail "An error occurred during application installation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
