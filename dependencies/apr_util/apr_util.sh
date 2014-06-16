# TODO: db4?
: ${APR_UTIL_DEPENDENCIES:=expat apr gdbm openssl}
: ${APR_UTIL_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-apr="$ROSE_SH_DEPS_PREFIX"
    --with-openssl="$ROSE_SH_DEPS_PREFIX"
    --with-expat="$ROSE_SH_DEPS_PREFIX"
    --with-dbm=db
    --with-berkeley-db="$ROSE_SH_DEPS_PREFIX"
    --with-crypto
  }
: ${APR_UTIL_TARBALL:="apr-util-1.5.2.tar.gz"}
: ${APR_UTIL_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/lib/aprutil.exp"}

#-------------------------------------------------------------------------------
install_apr_util()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${APR_UTIL_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${APR_UTIL_INSTALLED_FILE}" ]; then
      rm -rf "./apr_util"                           || fail "Unable to create application workspace"
      mkdir -p "apr_util"                           || fail "Unable to create application workspace"
      cd "apr_util/"                                || fail "Unable to change into the application workspace"

      download_tarball "${APR_UTIL_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${APR_UTIL_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${APR_UTIL_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ./configure ${APR_UTIL_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] apr_util is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
