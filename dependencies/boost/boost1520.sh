: ${BOOST1520_DEPENDENCIES:=python2712}
: ${BOOST1520_BOOTSTRAP_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --without-libraries=mpi 
    --without-icu
    --with-python="${ROSE_SH_DEPS_LIBDIR}/bin/python"
  }
: ${BOOST1520_CONFIGURE_OPTIONS:=
    -q
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${BOOST1520_TARBALL:="boost_1_56_0.tar.gz"}
: ${BOOST1520_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/boost/version.hpp"}

#-------------------------------------------------------------------------------
install_boost1520()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${BOOST1520_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${BOOST1520_INSTALLED_FILE}" ]; then
      rm -rf "./boost1520"                           || fail "Unable to remove old application workspace"
      mkdir -p "boost1520"                           || fail "Unable to create application workspace"
      cd "boost1520/"                                || fail "Unable to change into the application workspace"

      TARBALL_MIRROR_URLS=https://sourceforge.net/projects/boost/files/boost/1.56.0
      download_tarball "${BOOST1520_TARBALL}/download"        || fail "Unable to download application tarball"
      tar xzvf "download"                || fail "Unable to unpack application tarball"
      cd "$(basename ${BOOST1520_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      info "Bootstrapping Boost"
      "./bootstrap.sh" ${BOOST1520_BOOTSTRAP_OPTIONS} || fail "Unable to bootstrap Boost"

      info "Building Boost"
      BOOST_BUILD_CMD=
      if [ -e "$(pwd)/bjam" ]; then
          BOOST_BUILD_CMD="bjam"
      elif [ -e "$(pwd)/b2" ]; then
          BOOST_BUILD_CMD="b2"
      else
        fail "Could not find boost build script (bjam/b2)"
      fi

      "./${BOOST_BUILD_CMD}" install ${BOOST1520_CONFIGURE_OPTIONS} -j${parallelism} || fail "Unable to install Boost"
  else
      info "[SKIP] boost1520 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
