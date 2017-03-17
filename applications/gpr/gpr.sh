: ${GPR_DEPENDENCIES:= szip zeromq cppzmq libkml }
: ${GPR_CONFIGURE_OPTIONS:= 
  }
: ${REPOSITORY_MIRROR_URLS:= file:///usr/casc/overture/ROSE }
#-------------------------------------------------------------------------------
download_gpr()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      export REPOSITORY_MIRROR_URLS=file:///usr/casc/overture/ROSE
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_gpr()
#-------------------------------------------------------------------------------
{
  install_deps ${GPR_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_gpr()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_gpr__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------

  export APPLICATION_ABS_BUILDDIR=${application_abs_srcdir}/build
  rm -rf ${APPLICATION_ABS_BUILDDIR}
  mkdir -p ${APPLICATION_ABS_BUILDDIR}
  cd ${APPLICATION_ABS_BUILDDIR}

  export DDS_ROOT=${application_abs_srcdir}/tools/packages/openDDS/data-src/opt/DDS
  export ACE_ROOT=${application_abs_srcdir}/tools/packages/openDDS/data-src/opt/ACE_wrappers
  export ZMQ_ROOT=${ROSE_SH_DEPS_PREFIX}
  export BOOST_HOME=/nfs/casc/overture/ROSE/opt/rhel7/x86_64/boost/1_57_0/gcc/4.8.2
  export LD_LIBRARY_PATH=${DDS_ROOT}/lib/:${ACE_ROOT}/lib:${ZMQ_ROOT}/lib64:$LD_LIBRARY_PATH
  echo "JIMSEZ PWD = ${PWD}"
  echo "JIMSEZ APPLICATION_ABS_BUILDDIR = ${APPLICATION_ABS_BUILDDIR}"
  echo "JIMSEZ application_abs_srcdir = ${application_abs_srcdir}"

  cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_COMPILER=${CXX} -DOPENDDS_PATH=${DDS_ROOT}  -DACE_PATH=${ACE_ROOT} -DBOOST_ROOT=${BOOST_HOME} -DLibKML_DIR=${ROSE_SH_DEPS_PREFIX}/lib/cmake/libkml/ -DCMAKE_PREFIX_PATH=${ZMQ_ROOT}  ..
#-DCMAKE_CXX_COMPILER=${ROSE_CC}  Temporarily configure this for replay instead of straight build.
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_gpr__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CXX}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  #ask justin about boost
  export APPLICATION_ABS_BUILDDIR=${application_abs_srcdir}/build
  rm -rf ${APPLICATION_ABS_BUILDDIR}
  mkdir -p ${APPLICATION_ABS_BUILDDIR}
  cd ${APPLICATION_ABS_BUILDDIR}

  export DDS_ROOT=${application_abs_srcdir}/tools/packages/openDDS/data-src/opt/DDS
  export ACE_ROOT=${application_abs_srcdir}/tools/packages/openDDS/data-src/opt/ACE_wrappers
  export ZMQ_ROOT=${ROSE_SH_DEPS_PREFIX}
  export BOOST_HOME=/nfs/casc/overture/ROSE/opt/rhel7/x86_64/boost/1_57_0/gcc/4.8.2
  export LD_LIBRARY_PATH=${DDS_ROOT}/lib/:${ACE_ROOT}/lib:${ZMQ_ROOT}/lib64:$LD_LIBRARY_PATH
  echo "JIMSEZ PWD = ${PWD}"
  echo "JIMSEZ APPLICATION_ABS_BUILDDIR = ${APPLICATION_ABS_BUILDDIR}"
  echo "JIMSEZ application_abs_srcdir = ${application_abs_srcdir}"

  cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_COMPILER=${CXX} -DOPENDDS_PATH=${DDS_ROOT}  -DACE_PATH=${ACE_ROOT} -DBOOST_ROOT=${BOOST_HOME} -DLibKML_DIR=${ROSE_SH_DEPS_PREFIX}/lib/cmake/libkml/ -DCMAKE_PREFIX_PATH=${ZMQ_ROOT}  ..

#  export LD_LIBRARY_PATH=${application_abs_srcdir}/tools/packages/openDDS/data-src/opt/DDS/lib/:${application_abs_srcdir}/tools/packages/openDDS/data-src/opt/ACE_wrappers/lib:${ROSE_SH_DEPS_PREFIX}/zmq/lib64:${LD_LIBRARY_PATH}
#  export DDS_ROOT=${application_abs_srcdir}/tools/packages/openDDS/data-src/opt/DDS
#  cmake -DCMAKE_CXX_COMPILER=${CXX} -DOPENDDS_PATH=${application_abs_srcdir}/tools/packages/openDDS/data-src/opt/DDS  -DACE_PATH=${application_abs_srcdir}/tools/packages/openDDS/data-src/opt/ACE_wrappers -DBOOST_ROOT=/nfs/casc/overture/ROSE/opt/rhel7/x86_64/boost/1_57_0/gcc/4.8.2 -DLibKML_DIR=${ROSE_SH_DEPS_PREFIX}/lib/cmake/libkml/ -DZMQ_DIR=${ROSE_SH_DEPS_PREFIX}/zmq/share/cmake/ZeroMQ/ .. || fail "An error occurred during CMake bootstrapping"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_gpr()
#-------------------------------------------------------------------------------
{
  info "Compiling GPR with rose replay"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  export ROSE_CC
  export ROSE_CXX
  export APPLICATION_ABS_BUILDDIR=${application_abs_srcdir}/build
  cd ${APPLICATION_ABS_BUILDDIR}

  make -j --keep-going V=1 WXSTATIC=1 || fail "An error occurred during application build"

  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
replay_gpr()
#-------------------------------------------------------------------------------
{
  info "Compiling GPR with rose replay"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
          export ROSE_CC
          export ROSE_CXX

          # (1) Compile with GCC and save output for replay with ROSE
          #
          # Must compile serially in order to replay with ROSE... Actually, I
          # guess it may not be necessary since all dependencies are already
          # available... I guess for now we'll play it safe
          # Must run with verbose mode to get *all* compile lines
          #make -j$(cat /proc/cpuinfo | grep processor | wc -l) VERBOSE=1 2>&1 | tee output-mysql-make-gcc.txt || exit 1
          make -j32 VERBOSE=1 2>&1 | tee output-gpr-make-gcc.txt || exit 1
          if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            echo "[FATAL] GCC compilation failed. Terminating..."
            exit 1
          fi

          cat output-gpr-make-gcc.txt |    \
              grep --invert "\[.*%\]"    |    \
              grep --invert "^make "     |    \
              grep "cc\|c++\|gcc\|g++"        \
          > gcc-commandlines.txt || exit 1
              #FORTRAN# grep "cc\|c++\|gcc\|g++\|gfortran" \

          # (3) Replace gcc compile lines with ${ROSE_CXX} variable
          # WORKSPACE/rose-workspace/build to WORKSPACE/rose-workspace/sources
          ROSE_WORKSPACE_ESCAPED="$(echo ${ROSE_WORKSPACE} | sed 's/\//\\\//g')"
          cat gcc-commandlines.txt                                  | \
              sed 's/\(&&\) .*c++ /\1 \${ROSE_CXX} /'      | \
              sed 's/\(&&\) .*g++ /\1 \${ROSE_CXX} /'      | \
              sed 's/\(&&\) .*cc /\1 \${ROSE_CC} /'        | \
              sed 's/\(&&\) .*gcc /\1 \${ROSE_CC} /'       | \
              sed 's/^cd \(.*\) \(&& .*\)/cd "\$(dirname \1)" \2/' | \
              sed 's/^\(.* -o\) \(CMakeFiles\/.*\.o\) \(.*\)/mkdir -p "\$(dirname \2)"; \1 \2 \3/' \
          > make-rose-commandlines.txt
              #FORTRAN#sed 's/\(&&\) .*gfortran/\1 \${ROSE_GFORTRAN}/'      | \

          cat <<EOF | cat - make-rose-commandlines.txt | sed 's/\(^\${ROSE_CXX}.*\)$/\1 || true/g' > make-rose.sh
#!/bin/bash

export application_abs_srcdir="${application_abs_srcdir}"

if [ -z "\${ROSE_CXX}" ]; then
  echo "[FATAL] ROSE_CXX is undefined"
  exit 1
elif [ -z "\${ROSE_CC}" ]; then
  echo "[FATAL] ROSE_CC is undefined"
  exit 1
#elif [ -z "\${ROSE_GFORTRAN}" ]; then
#  echo "[FATAL] ROSE_GFORTRAN is undefined"
#  exit 1
else
  echo "[DEBUG] ROSE_CXX='\${ROSE_CXX}'"
  echo "[DEBUG] ROSE_CC='\${ROSE_CC}'"
  echo "[DEBUG] LD_LIBRARY_PATH='\${LD_LIBRARY_PATH}'"
  echo "[DEBUG] PATH='\${PATH}'"
fi
EOF

          chmod +x make-rose.sh
          time ./make-rose${ROSE_DEBUG:+-debug}.sh || exit 1

# Extract results from Sqlite database and save to files:
#
#     rose-passes.txt
#     rose-failures.txt
#
sqlite3 "${application_abs_srcdir}/rose-results.db" > "${application_abs_srcdir}/rose-passes.txt" <<SQL
SELECT filename FROM results WHERE passed=1;
SQL

sqlite3 "${application_abs_srcdir}/rose-results.db" > "${application_abs_srcdir}/rose-failures" <<SQL
SELECT filename FROM results WHERE passed=0;
SQL
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
