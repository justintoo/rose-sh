: ${ROSE_SPACK_LC_DEPENDENCIES:=}
: ${ROSE_SPACK_LC_CONFIGURE_OPTIONS:=
  }

: ${COMPILER_SPEC:=%gcc@4.8.5}
: ${BOOST_SPEC:="boost@1.56.0"}
: ${ROSE_BRANCH:=master}
: ${ROSE_BRANCH_VARIANT_NAME:=}

#-------------------------------------------------------------------------------
download_rose_spack_lc()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      #clone_repository "${application}" "${application}-src" || exit 1
      git clone --branch rose-jenkins https://github.com/justintoo/spack.git "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
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

git clone --branch "${ROSE_BRANCH}" https://github.com/rose-compiler/rose-develop.git rose --reference /g/g12/too1/projects/rose.git || exit 1
pushd rose/
    export ROSE_COMMIT="$(git log HEAD -1 --format=%H)"
    export ROSE_VERSION="$(cat ./ROSE_VERSION)${ROSE_BRANCH_VARIANT_NAME}"
    git log -3 | tee git-log.txt
popd
rm -rf rose/ || exit 1

if [ -z "${ROSE_COMMIT}" ]; then
  echo "[FATAL] \$ROSE_COMMIT is not set. Please set this environment variable to the ROSE Git commit that you want to add."
  exit 1
else
  echo "[INFO] ROSE_COMMIT='${ROSE_COMMIT}'"
fi

if [ -z "${ROSE_VERSION}" ]; then
  echo "[FATAL] \$ROSE_VERSION is not set. Please set this environment variable to the ROSE version number (x.x.x.x) that you want to add."
  exit 1
else
  echo "[INFO] ROSE_VERSION='${ROSE_VERSION}'"
fi

  set +x
}

#-------------------------------------------------------------------------------
install_deps_rose_spack_lc()
#-------------------------------------------------------------------------------
{
  install_deps ${ROSE_SPACK_LC_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_rose_spack_lc()
#-------------------------------------------------------------------------------
{
  info "Patching application"

  #------------------------------------------------------------------
  # Update ROSE-Spack package with latest development version
  #------------------------------------------------------------------
  sed -i \
    -e "s/__ROSE_COMMIT__/${ROSE_COMMIT}/" \
    -e "s/__ROSE_VERSION__/${ROSE_VERSION}/" \
    "${SPACK_HOME}/var/spack/repos/builtin/packages/rose/package.py"
  
  #------------------------------------------------------------------
  # Update ROSE-Spack package with boost version
  #------------------------------------------------------------------
  sed -i \
    -e "s/__BOOST_VERSION__/${BOOST_SPEC}/" \
    "${SPACK_HOME}/var/spack/repos/builtin/packages/rose/package.py"
}

#-------------------------------------------------------------------------------
configure_rose_spack_lc__rose()
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
configure_rose_spack_lc__gcc()
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
compile_rose_spack_lc()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      #------------------------------------------------------------------
      # Install ROSE
      # TOO1 (10/18/16): Using --no-checksum for libtool 2.4
      # TOO1 (02/22/17): Using NFS TMPDIR for srun
      #------------------------------------------------------------------
      TMPDIR="/nfs/tmp2/${USER}" \
        spack --verbose --insecure install --keep-stage --no-checksum rose@"${ROSE_VERSION}" ${COMPILER_SPEC} || exit 1

#------------------------------------------------------------------
# Report Usage Information
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
echo "    \$ spack load rose@0.9.7.100"
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
spack load rose@"${ROSE_VERSION}"

# Create setup.sh for developers testing ROSE in the Spack installation prefix
cat > "${ROSE_HOME}/setup.sh" <<-SCRIPT
export ROSE_VERSION="rose-${ROSE_VERSION}"
export ROSE_HOME="${ROSE_HOME}"


# TODO Remove after release
export PATH="\${ROSE_HOME}/bin:\${PATH}"

#------------------------------------------------------------------------------
# Load Spack into shell environment
#------------------------------------------------------------------------------
export SPACK_HOME="/collab/usr/global/tools/rose/release/.spack"
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
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
