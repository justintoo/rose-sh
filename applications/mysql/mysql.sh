: ${MYSQL_DEPENDENCIES:=ncurses}
: ${MYSQL_CONFIGURE_OPTIONS:=
  }

#-------------------------------------------------------------------------------
download_mysql()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      #clone_repository "${application}" "${application}-src" || exit 1
      #cd "${application}-src/" || exit 1
      #source /nfs/casc/overture/ROSE/opt/rhel7/x86_64/ncurses/6.0/setup.sh

      wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-boost-5.7.17.tar.gz
      tar xzvf mysql-boost-5.7.17.tar.gz
      ln -sf mysql-5.7.17 mysql-src
      cd mysql-src

      wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
      tar xzvf boost_1_59_0.tar.gz
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
      #CC="gcc" \
      #CXX="g++" \
      #CPPFLAGS="$CPPFLAGS" \
      #CFLAGS="$CFLAGS"  \
      #LDFLAGS="$LDFLAGS"  \
      LDFLAGS= \
      CPPFLAGS= \
      CXXFLAGS= \
      CFLAGS= \
      cmake . \
        -DWITH_BOOST="$(pwd)/boost_1_59_0" \
        -DCURSES_LIBRARY="${ROSE_SH_DEPS_PREFIX}/lib/libncurses.so" \
        -DCURSES_INCLUDE_PATH="${ROSE_SH_DEPS_PREFIX}/include" \
        -DCMAKE_CXX_FLAGS="-ltinfo -L${ROSE_SH_DEPS_PREFIX}/lib"|| fail "An error occurred during CMake bootstrapping"
      #cmake . -DENABLE_DOWNLOADS=1 || fail "An error occurred during CMake bootstrapping"
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
          make -j$(cat /proc/cpuinfo | grep processor | wc -l) VERBOSE=1 2>&1 | tee output-mysql-make-gcc.txt || exit 1
#          make -j32 VERBOSE=1 2>&1 | tee output-mysql-make-gcc.txt || exit 1
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
              grep --invert "^Building CXX object "     |    \
              grep --invert "is newer than depender"     |    \
              grep "cc\|c++\|gcc\|g++"        \
          > gcc-commandlines.txt || exit 1
              #FORTRAN# grep "cc\|c++\|gcc\|g++\|gfortran" \

          # (3) Replace gcc compile lines with ${ROSE_CXX} variable
          #
          # Building CXX object
          # (1) Grep for only ROSE_CXX commandlines, else
          #
          #     $ cat make-rose-commandlines.txt  | grep "ROSE_CC\|ROSE_CXX"
          #
          # (2) Remove all extra commandlines
          #
          #     $ cat make-rose-commandlines.txt  | grep --invert "ROSE_CC" | grep --invert "ROSE_CXX" | grep --invert "^Building CXX object " | grep --invert c++ | grep --invert "\/usr\/bin\/ar" | grep --invert "Built target" | grep --invert "^Building C object " | grep --invert "libprotobuf WARNING" | grep --invert "/usr/bin/cc" | grep --invert "cmake_depends" | grep --invert "^Dependee " | grep --invert "Scanning dependencies of " | grep --invert "Linking CXX executable" | grep --invert "/usr/bin/cmake"

          # Reorder so `mkdir` comes after `cd`:
          # sed 's/^\(mkdir.*\); \(cd .*\) && \(.*\)/\2 \&\& \1 \&\& \3/' \

          cat gcc-commandlines.txt                                  | \
              sed 's/\(&&\) .*c++ /\1 \${ROSE_CXX} /'      | \
              sed 's/\(&&\) .*g++ /\1 \${ROSE_CXX} /'      | \
              sed 's/\(&&\) .*cc /\1 \${ROSE_CC} /'        | \
              sed 's/\(&&\) .*gcc /\1 \${ROSE_CC} /'       | \
              sed 's/^cd \(.*\) \(&& .*\)/cd "\$(dirname \1)" \2/' | \
              sed 's/^\(.* -o\) \(CMakeFiles\/.*\.o\) \(.*\)/mkdir -p "\$(dirname \2)"; \1 \2 \3/' | \
              grep "ROSE_CC\|ROSE_CXX" | \
              sed 's/^\(mkdir.*\); \(cd .*\) && \(.*\)/\2 \&\& \1 \&\& \3/' \
          > make-rose-commandlines.txt
              #FORTRAN#sed 's/\(&&\) .*gfortran/\1 \${ROSE_GFORTRAN}/'      | \

          cat <<EOF | cat - make-rose-commandlines.txt | sed 's/\(^\${ROSE_CXX}.*\)$/\1 || true/g' > make-rose-sequential.sh
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

          # TOO1 (04/11/17): Run sequential commandlines
          #chmod +x make-rose-sequential.sh
          #time ./make-rose${ROSE_DEBUG:+-debug}.sh || exit 1

          # Sort by last column, which should be the MySQL input filename
          # (http://stackoverflow.com/questions/1915636/is-there-a-way-to-uniq-by-column)
          cat make-rose-commandlines.txt | awk -F" " '!_[$NF]++' > make-rose-commandlines-unique.txt

          # Generate a Makefile of all the commandlines in order to:
          #
          #   1. Conveniently re-run the command manually with make 
          #   2. Run in parallel with `make -jN`

          # Create new empty file                  
          ROSE_MAKEFILE="make-rose-commandlines.makefile"
          cat > "${ROSE_MAKEFILE}" <<MAKEFILE
V = 0
V_0 = @echo "Compiling \$@";
V_1 =
VERBOSE = \$(V_\$(V))

LOG_OUTPUT_0 = 1>/dev/null
LOG_OUTPUT_1 =
LOG_OUTPUT = \$(LOG_OUTPUT_\$(V))
MAKEFILE
          
          # Variable to hold list of all make targets
          targets=""
          
          while read -r rose_cmdline || [[ -n "$line" ]]; do
            filepath="$(echo "${rose_cmdline}" | sed 's/.* -c \(.*\)$/\1/')"
            basename="$(basename "${filepath}")"
            extension="${basename##*.}"
            filename="${basename%.*}"

            # Input: cd "$$(dirname /export/tmp.hudson-rose/tmp/ROSESH-13-mysql-parallel-replay/rose-sh/workspace/mysql/phase_1/mysql-5.7.17/storage/perfschema/unittest)" &&
            directory="$(dirname "${filepath}")"
            # relative directory within the MySQL source tree
            relative_directory="${directory#${application_abs_srcdir}/}"

            # add to "make all" target
            targets="${targets} ${relative_directory}/rose_${basename}"

            # make rose_<filename>.<extension>
            # Escape $ in makefiles: sed 's/[$]/$$/g'
            cat >> "${ROSE_MAKEFILE}" <<MAKEFILE

${relative_directory}/rose_${basename}: ${filepath}
$(echo -e "\t\$(VERBOSE)$(echo "${rose_cmdline}" | sed 's/[$]/$$/g')\n\n") \$(LOG_OUTPUT)
MAKEFILE
            #echo "${basename}:" >> "${ROSE_MAKEFILE}"
            #echo -e "\t$(echo "${rose_cmdline}" | sed 's/[$]/$$/g')\n\n" >> "${ROSE_MAKEFILE}"
          done < "make-rose-commandlines-unique.txt"

          # add all targets to default Make target "all"
          echo "all: ${targets}" >> "${ROSE_MAKEFILE}"
          
          make VERBOSE=1 -j${parallelism} -f "${ROSE_MAKEFILE}" || fail "An error occurred during application compilation"

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
