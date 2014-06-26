: ${FILE_DEPENDENCIES:=zlib}
: ${FILE_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-static
  }
: ${FILE_TARBALL:="file-5.14.tar.gz"}
: ${FILE_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/bin/file"}

#-------------------------------------------------------------------------------
install_file()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${FILE_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${FILE_INSTALLED_FILE}" ]; then
      rm -rf "./file"                           || fail "Unable to remove old application workspace"
      mkdir -p "file"                           || fail "Unable to create application workspace"
      cd "file/"                                || fail "Unable to change into the application workspace"

      download_tarball "${FILE_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${FILE_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${FILE_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${FILE_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] file is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
