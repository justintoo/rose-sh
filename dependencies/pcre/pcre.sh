: ${PCRE_DEPENDENCIES:=zlib bzip2 readline}
: ${PCRE_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --exec-prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_PREFIX}/lib"
    --enable-unicode-properties
    --enable-utf
    --enable-pcregrep-libz
    --enable-pcregrep-libbz2
  }
# TOO1 (02/28/2017): Failing to detect readline dependency; bypassing for
# now since PCRE still compiles without this option. Need PCRE in toolchain
# for TrueCrypt [ROSESH-2]
#    --enable-pcretest-libreadline
: ${PCRE_TARBALL:="pcre-8.31.tar.gz"}
: ${PCRE_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/pcre.h"}

#-------------------------------------------------------------------------------
install_pcre()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${PCRE_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${PCRE_INSTALLED_FILE}" ]; then
      rm -rf "./pcre"  || fail "Unable to create application workspace"
      mkdir -p "pcre"  || fail "Unable to create application workspace"
      cd "pcre/"       || fail "Unable to change into the application workspace"

      download_tarball "${PCRE_TARBALL}"        || fail "Unable to unpack application tarball"
      tar xzvf "${PCRE_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${PCRE_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      LIBS="-lncurses" \
        ./configure ${PCRE_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] pcre is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
