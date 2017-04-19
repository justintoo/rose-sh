: ${ROSE_MATRIX_RESULTS_DEPENDENCIES:=}
: ${ROSE_MATRIX_RESULTS_CONFIGURE_OPTIONS:=
  }
: ${ROSE_COMMIT:=master}

#-------------------------------------------------------------------------------
download_rose_matrix_results()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || "Unable to clone the ROSE source code"
      cd "${application}-src/" || exit 1
      git submodule update --init || fail "Unable to clone the EDG source code"
      git checkout ${ROSE_COMMIT}
      export ROSE_VERSION="$(cat ./ROSE_VERSION)${ROSE_BRANCH_VARIANT_NAME}"
      if test $? -ne 0 || test -z "${ROSE_VERSION}"; then
        fail "Unable to determine the ROSE_VERSION"
      fi
  set +x
}

#-------------------------------------------------------------------------------
install_deps_rose_matrix_results()
#-------------------------------------------------------------------------------
{
  install_deps ${ROSE_MATRIX_RESULTS_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_rose_matrix_results()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_rose_matrix_results__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  # Setup toolchain before configuration
  source /usr/local/tools/dotkit/init.sh || true
  use gcc-4.8.5p || fail "Unable to source GCC 4.8.5"
  use mvapich2-intel-1.9 || fail "Unable to source Intel 16"
  source /g/g12/too1/opt/boost/1.52.0/gcc/4.8.5/setup.sh || fail "Unable to source Boost 1.52.0"

  # Configure ROSE in a separate build directory
  export ROSE_COMPILATION="${application_abs_srcdir}/rose-compilation"
  export ROSE_INSTALLATION="${application_abs_srcdir}/rose-installation"
  ../configure \
      --prefix="${ROSE_INSTALLATION}" \
      --enable-edg_version=4.12 \
      --without-java \
      --with-boost="${BOOST_HOME}" \
      --with-alternate_backend_C_compiler="$(which mpicc)" \
      --with-alternate_backend_Cxx_compiler="$(which mpicxx)" \
      --disable-boost-version-check \
      --enable-languages=c,c++,fortran,binaries \
      ${ROSE_MATRIX_RESULTS_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_rose_matrix_results__gcc()
#-------------------------------------------------------------------------------
{
  fail "Not implemented"
}

#-------------------------------------------------------------------------------
compile_rose_matrix_results()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  srun -ppdebug make -j${parallelism} || fail "An error occurred during application installation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
