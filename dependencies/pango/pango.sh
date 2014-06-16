: ${PANGO_DEPENDENCIES:=cairo fontconfig harfbuzz}
: ${PANGO_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${PANGO_TARBALL:="pango-1.36.1.tar.xz"}
: ${PANGO_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/pango-1.0/pango/pango.h"}

#-------------------------------------------------------------------------------
install_pango()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${PANGO_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${PANGO_INSTALLED_FILE}" ]; then
      rm -rf "./pango"  || fail "Unable to remove application workspace"
      mkdir -p "pango"  || fail "Unable to create application workspace"
      cd "pango/"       || fail "Unable to change into the application workspace"

      download_tarball "${PANGO_TARBALL}"       || fail "Unable to download application tarball"
      unxz "${PANGO_TARBALL}"                   || fail "Unable to unpack application tarball"
      tar xvf "${PANGO_TARBALL%.xz}"            || fail "Unable to unpack application tarball"
      cd "$(basename ${PANGO_TARBALL%.tar.xz})" || fail "Unable to change into application source directory"

      # TOO1 (2/7/2014): GCC versions (I think before 4.6) do not halt with failure
      #                  on certain CLI errors. For example:
      #
      #                     "cc1: error: unrecognized command line option "-framework"
      #
      #                  Therefore, the configuration test passes, as a false positive, wrongly
      #                  indicating that a certain library/feature is available.
      #
      #                  In this case, a check for Apple/Darwin CoreText library is being
      #                  check via "-framework" Darwin GCC option.
      perl -pi -e \
          's/\-framework/CLI_ERROR/g' \
          configure                          || fail "Unable to patch configure.ac"

      ./configure ${PANGO_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] pango is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
