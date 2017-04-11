: ${ROSE_SPACK_LC_DEPENDENCIES:=}
: ${ROSE_SPACK_LC_CONFIGURE_OPTIONS:=
  }

: ${COMPILER_SPEC:=%gcc@4.8.5}
: ${BOOST_SPEC:="boost@1.56.0"}
: ${ROSE_BRANCH_VARIANT_NAME:=}

#-------------------------------------------------------------------------------
download_rose_spack_lc_historical()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      #clone_repository "${application}" "${application}-src" || exit 1
      git clone https://github.com/rose-compiler/rose-develop.git rose --reference /g/g12/too1/projects/rose.git || exit 1
      cd rose/ || exit 1
      export ROSE_SRC="$(pwd)"
      bootstrap_rose_spack_lc_historical
  set +x
}

#-------------------------------------------------------------------------------
bootstrap_rose_spack_lc_historical()
#-------------------------------------------------------------------------------
{
  git clone --branch rose-jenkins https://github.com/justintoo/spack.git || exit 1
  cd spack/
  export SPACK_HOME="$(pwd)"

  cat > "${SPACK_HOME}/setup-new.sh" <<-EOF
# Add Spack to shell environment
export SPACK_HOME="${SPACK_HOME}"
export PATH="\${SPACK_HOME}/bin:\${PATH}"

# Provide Spack's shell support
source "\${SPACK_HOME}/share/spack/setup-env.sh"

# Provide Dot kit support
. /usr/local/tools/dotkit/init.sh || true
use mvapich2-intel-1.9 || true

use gcc-4.8.5p || true
EOF

  #------------------------------------------------------------------
  # Add Spack to the Shell Environment
  #------------------------------------------------------------------
  source "${SPACK_HOME}/setup-new.sh"
  
  # Add gcc-4.8.5p
  spack compiler find

  #------------------------------------------------------------------
  # Update ROSE-Spack package with boost version
  #------------------------------------------------------------------
  sed -i \
    -e "s/__BOOST_VERSION__/${BOOST_SPEC}/" \
    "${SPACK_HOME}/var/spack/repos/builtin/packages/rose/package.py"
}

#-------------------------------------------------------------------------------
install_deps_rose_spack_lc_historical()
#-------------------------------------------------------------------------------
{
  install_deps ${ROSE_SPACK_LC_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_rose_spack_lc_historical()
#-------------------------------------------------------------------------------
{
  info "No patches needed"
}

#-------------------------------------------------------------------------------
configure_rose_spack_lc_historical__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_rose_spack_lc_historical__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_rose_spack_lc_historical()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------

  # ================================================================
  # (1) Generate ROSE commits to test
  # ================================================================
  pushd "${ROSE_SRC}"
    commits="$(git log --oneline --pretty=format:"%h" -- ROSE_VERSION)"
    num_commits="$(git log --oneline --pretty=format:"%h" -- ROSE_VERSION | wc -l)"
  popd
  echo "================================================================"
  echo "==== Testing [${num_commits}] commits"
  echo "================================================================"
  
  # ================================================================
  # (2) Iterate over every ROSE commit from (1)
  # ================================================================
  loopNum=1
  for commit in ${commits}; do
    # ================================================================
    # (2.1) Obtain ROSE version vX.X.X.X for this ROSE commit from the ROSE repository
    # ================================================================
    pushd "${ROSE_SRC}"
      git checkout "${commit}" || exit 1
      export ROSE_COMMIT="$(git log HEAD -1 --format=%H)"
      export ROSE_VERSION="$(cat ./ROSE_VERSION)${ROSE_BRANCH_VARIANT_NAME}"
    popd

    echo "================================================================"
    echo "==== [${loopNum}/${num_commits}] Installing ROSE '${ROSE_VERSION}' '${ROSE_COMMIT}'"
    echo "================================================================"

    # ================================================================
    # (2.2) Add this ROSE commit and version to Spack
    # ================================================================
    # (2.2.1) Define a new ROSE version for SPACK/...../rose/package.py
    # Note: Using 4 leading spaces to match the indentation in rose/package.py
    echo "    version('__ROSE_VERSION__', commit='__ROSE_COMMIT__', git='rose-dev@rosecompiler1.llnl.gov:rose/scratch/rose.git')" | \
      sed \
        -e "s/__ROSE_COMMIT__/${ROSE_COMMIT}/" \
        -e "s/__ROSE_VERSION__/${ROSE_VERSION}/" \
      > rose-version.txt

    # (2.2.2) Insert new ROSE version into SPACK/...../rose/package.py 
    sed -i \
      -e '/ADD_EXTRA_VERSIONS_HERE/ r rose-version.txt' \
      "${SPACK_HOME}/var/spack/repos/builtin/packages/rose/package.py"

    #------------------------------------------------------------------
    # (3) Install ROSE
    # TOO1 (10/18/16): Using --no-checksum for libtool 2.4
    # TOO1 (02/22/17): Using NFS TMPDIR for srun
    #------------------------------------------------------------------
    TMPDIR="/nfs/tmp2/${USER}" \
      spack --verbose --insecure install --keep-stage --no-checksum rose@"${ROSE_VERSION}" ${COMPILER_SPEC} || exit 1
    if [ $? -eq 0 ]; then
      # Record passing installation
      echo "${ROSE_VERSION} ${ROSE_COMMIT}" >> rose-passes.txt
    else
      # Record failed installation
      echo "${ROSE_VERSION} ${ROSE_COMMIT}" >> rose-failures.txt
    fi
    
    echo "================================================================"
    echo "==== [${loopNum}/${num_commits}] Installed ROSE '${ROSE_VERSION}' '${ROSE_COMMIT}'"
    echo "================================================================"

    #------------------------------------------------------------------
    # (3.1) Create setup.sh file for this ROSE installation
    #------------------------------------------------------------------
      cat >> "${SPACK_HOME}/setup-new.sh" <<-EOF
  # Add ROSE installation home to shell variable
  export ROSE_HOME="$(spack location -i rose@${ROSE_VERSION})"
  
  # Show ROSE versions
  spack info rose
  
  # Show usage information for latest ROSE version
  echo
  echo "To use a specific version of ROSE, please load it with spack:"
  echo
  echo "    \$ spack load rose@<x.x.x.x>"
  echo
  echo "Now loading the latest ROSE release v${ROSE_VERSION}:"
  echo
  echo "    \$ spack load rose@${ROSE_VERSION}"
  echo
  
  spack load rose@${ROSE_VERSION}
EOF
  
  # Update the setup.sh file
  cp "${SPACK_HOME}/setup-new.sh" "${SPACK_HOME}/setup.sh"
  
  chmod a+r "${SPACK_HOME}/setup-new.sh"
  chgrp rose "${SPACK_HOME}/setup-new.sh"
  
  chmod a+r "${SPACK_HOME}/setup.sh"
  chgrp rose "${SPACK_HOME}/setup.sh"
  
  source "${SPACK_HOME}/setup.sh"

  # Create setup.sh for developers testing ROSE in the Spack installation prefix
  cat > "${ROSE_HOME}/setup.sh" <<-SCRIPT
export ROSE_VERSION="rose-${ROSE_VERSION}"
export ROSE_HOME="${ROSE_HOME}"

# TODO Remove after release
export PATH="\${ROSE_HOME}/bin:\${PATH}"

#------------------------------------------------------------------------------
# Load Spack into shell environment
#------------------------------------------------------------------------------
export SPACK_HOME="${SPACK_HOME}"
export PATH="\${SPACK_HOME}/bin:\${PATH}"

#------------------------------------------------------------------------------
# Load Spack's shell support
#------------------------------------------------------------------------------
source "\${SPACK_HOME}/share/spack/setup-env.sh"

#------------------------------------------------------------------------------
# Load Intel compiler into shell environment
#------------------------------------------------------------------------------
. /usr/local/tools/dotkit/init.sh || true
use mvapich2-intel-1.9 >/dev/null || true

#------------------------------------------------------------------------------
# Load ROSE into shell environment
#------------------------------------------------------------------------------
spack load rose@\${ROSE_VERSION} || false

#------------------------------------------------------------------------------
# Display ROSE Backend Compiler
#------------------------------------------------------------------------------
cat <<-EOF
\$(identityTranslator --version)
  --- using backend C compiler: mpiicc v$(mpicc -dumpversion)
  --- using backend C++ compiler: mpiic++ v$(mpic++ -dumpversion)
  --- using ROSE_HOME: '\${ROSE_HOME}'
EOF
SCRIPT
  
    chmod a+r "${ROSE_HOME}/setup.sh"
    
    let "loopNum=loopNum+1"
  done
      
  passes="$(cat rose-passes.txt | wc -l)"
  failures="$(cat rose-failures.txt | wc -l)"
  
  echo "================================================================"
  echo " === Installed [${num_commits}] ROSE versions"
  echo " ==="
  echo " ===   Passes:     ${passes}/${num_commits} (rose-passes.txt)"
  echo " ===   Failures:   ${failures}/${num_commits} (rose-failures.txt)"
  echo "================================================================"

  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
