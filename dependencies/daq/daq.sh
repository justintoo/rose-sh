: ${DAQ_DEPENDENCIES:=libpcap libdnet}
: ${DAQ_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-libpcap-includes="${ROSE_SH_DEPS_PREFIX}/include"
    --with-libpcap-libraries="${ROSE_SH_DEPS_PREFIX}/lib"
  }
: ${DAQ_TARBALL:="daq-2.0.1.tar.gz"}
: ${DAQ_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/daq.h"}

#-------------------------------------------------------------------------------
install_daq()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${DAQ_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${DAQ_INSTALLED_FILE}" ]; then
      rm -rf "./daq"  || fail "Unable to remove old application workspace"
      mkdir -p "daq"  || fail "Unable to create application workspace"
      cd "daq/"       || fail "Unable to change into the application workspace"

      download_tarball "${DAQ_TARBALL}"       || fail "Unable to download application tarball"
      tar xzvf "${DAQ_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${DAQ_TARBALL%.tar.gz})" || fail "Unable to change into application source directory"

      ./configure ${DAQ_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] daq is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
