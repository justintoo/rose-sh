: ${XEN_DEPENDENCIES:=dev86 iasl libuuid libaio yajl}
: ${XEN_CONFIGURE_OPTIONS:=
    --enable-githttp
    --disable-stubdom
  }

#-------------------------------------------------------------------------------
download_xen()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      #clone_repository "${application}" "${application}-src" || exit 1
      #cd "${application}-src/" || exit 1
      wget --no-check-certificate http://www.xenproject.org/downloads/xen-archives/xen-44-series/xen-440/299-xen-project-440/file.html || exit 1
      tar xzvf file.html || exit 1
      cd xen-4.4.0/ || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_xen()
#-------------------------------------------------------------------------------
{
  install_deps ${XEN_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_xen()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_xen__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
          PREPEND_INCLUDES="${ROSE_SH_DEPS_PREFIX}/include" \
          PREPEND_LIB="${ROSE_SH_DEPS_PREFIX}/lib" \
          CC="${ROSE_CC}" \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${XEN_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_xen__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
          PREPEND_INCLUDES="${ROSE_SH_DEPS_PREFIX}/include" \
          PREPEND_LIB="${ROSE_SH_DEPS_PREFIX}/lib" \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${XEN_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_xen()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      # TOO1 (2/18/2014): Force parallelism=1 since parallel build fails.
      #parallelism=1
      make dist -j1         || fail "An error occurred during application compilation"
# TODO:
#      make -j${parallelism} install || fail "An error occurred during application installation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
