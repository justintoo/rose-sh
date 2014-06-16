: ${LIBPCAP_DEPENDENCIES:=}
: ${LIBPCAP_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${LIBPCAP_TARBALL:="libpcap-1.4.0.tar.gz"}
: ${LIBPCAP_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/pcap.h"}

#-------------------------------------------------------------------------------
install_libpcap()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBPCAP_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBPCAP_INSTALLED_FILE}" ]; then
      rm -rf "./libpcap"  || fail "Unable to remove old application workspace"
      mkdir -p "libpcap"  || fail "Unable to create application workspace"
      cd "libpcap/"       || fail "Unable to change into the application workspace"

      download_tarball "${LIBPCAP_TARBALL}"       || fail "Unable to download application tarball"
      tar xzvf "${LIBPCAP_TARBALL}"               || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBPCAP_TARBALL%.tar.gz})" || fail "Unable to change into application source directory"

      ./configure ${LIBPCAP_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] libpcap is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
