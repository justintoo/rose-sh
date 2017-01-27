: ${MYSQL_DEPENDENCIES:=ncurses}
: ${MYSQL_CONFIGURE_OPTIONS:=
  }

#-------------------------------------------------------------------------------
download_mysql()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
      wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
  set +x
}

#-------------------------------------------------------------------------------
install_deps_mysql()
#-------------------------------------------------------------------------------
{
  install_deps ${MYSQL_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_mysql()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_mysql__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      #CC="${ROSE_CC}" \
      #CXX="${ROSE_CXX}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
      cmake . -DDOWNLOAD_BOOST=1 -DWITH_BOOST="$(pwd)" || fail "An error occurred during CMake bootstrapping"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_mysql__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CXX}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      fatal "Not implemented yet"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_mysql()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

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
          make -j1 VERBOSE=1 2>&1 | tee output-mysql-make-gcc.txt || exit 1
          if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            echo "[FATAL] GCC compilation failed. Terminating..."
            exit 1
          fi

#cat CMakeCache.txt | \
#    sed 's/^\(CMAKE_Fortran_COMPILER:STRING\)=.*/\1=\${ROSE_GFORTRAN}/' | \
#    sed 's/^\(CMAKE_C_COMPILER:STRING\)=.*/\1=\${ROSE_CC}/'             | \
#    sed 's/^\(CMAKE_CXX_COMPILER:STRING\)=.*/\1=\${ROSE_CXX}/'          \
#  > CMakeCache.txt-new
#
#mv CMakeCache.txt CMakeCache.txt-old
#cp CMakeCache.txt-new CMakeCache.txt
#
#make
#          if [ "${PIPESTATUS[0]}" -ne 0 ]; then
#            echo "[FATAL] GCC compilation failed. Terminating..."
#            exit 1
#          else
#            exit 0
#          fi

          # cd mysql-src/Src/F_BaseLib && /nfs/apps/gcc/4.9.2/bin/gfortran
          #                             && /nfs/apps/gcc/4.9.2/bin/gcc
          #                             && /nfs/apps/gcc/4.9.2/bin/g++
          cat output-mysql-make-gcc.txt |    \
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
if [ -z "\${ROSE_CXX}" ]; then
  echo "[FATAL] ROSE_CXX is undefined"
  exit 1
elif [ -z "\${ROSE_CC}" ]; then
  echo "[FATAL] ROSE_CC is undefined"
  exit 1
elif [ -z "\${ROSE_GFORTRAN}" ]; then
  echo "[FATAL] ROSE_GFORTRAN is undefined"
  exit 1
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

    #make VERBOSE=1 -j1 || fail "An error occurred during application compilation"

  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
