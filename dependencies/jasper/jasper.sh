: ${JASPER_DEPENDENCIES:=libjpeg}
: ${JASPER_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-shared
    --without-x
  }
: ${JASPER_TARBALL:="jasper-1.900.1.tar.gz"}
: ${JASPER_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/jasper/jasper.h"}

#-------------------------------------------------------------------------------
install_jasper()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${JASPER_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${JASPER_INSTALLED_FILE}" ]; then
      rm -rf "./jasper"  || fail "Unable to remove old application workspace"
      mkdir -p "jasper"  || fail "Unable to create application workspace"
      cd "jasper/"       || fail "Unable to change into the application workspace"

      download_tarball "${JASPER_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${JASPER_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${JASPER_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      # TOO1 (2/10/2014): RHEL6: Add CFLAGS/LDFLAGS in order to find libjpeg.
      CFLAGS="${CFLAGS}" \
      LDFLAGS="${LDFLAGS}" \
          ./configure ${JASPER_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] jasper is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
