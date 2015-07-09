: ${XEN_DEPENDENCIES:=dev86 iasl libuuid libaio yajl pixman}
: ${XEN_CONFIGURE_OPTIONS:=
    --enable-githttp
    --disable-stubdom
  }

#-------------------------------------------------------------------------------
download_xen()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  wget -O- --no-check-certificate www.google.com | grep "LLNL User Identification Portal"
  if test $? -eq 0; then
    echo "[FATAL] Xen requires access to the Internet."
    echo "[FATAL] Please open a browser and authenticate through the LLNL USER Identification Portal"
    exit 1
  fi

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
      #if [ ! -d "xen-src" ]; then
      #    wget --no-check-certificate http://www.xenproject.org/downloads/xen-archives/xen-44-series/xen-440/299-xen-project-440/file.html || exit 1
      #    tar xzvf file.html || exit 1
      #    mv xen-4.4.0/ xen-src || exit 1
      #fi
      #cd xen-src || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_xen()
#-------------------------------------------------------------------------------
{
  install_deps ${XEN_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_xen()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_xen__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      PREPEND_INCLUDES="${ROSE_SH_DEPS_PREFIX}/include" \
      PREPEND_LIB="${ROSE_SH_DEPS_PREFIX}/lib" \
      ./configure \
          --prefix="$(pwd)/install_tree" \
          ${XEN_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_xen__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      PREPEND_INCLUDES="${ROSE_SH_DEPS_PREFIX}/include" \
      PREPEND_LIB="${ROSE_SH_DEPS_PREFIX}/lib" \
      ./configure \
          --prefix="$(pwd)/install_tree" \
          ${XEN_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_xen()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
          export ROSE_CC
          # (1) Compile with GCC and save output for replay with ROSE
          #
          # Must compile serially in order to replay with ROSE... Actually, I
          # guess it may not be necessary since all dependencies are already
          # available... I guess for now we'll play it safe
          # Must run with verbose mode to get *all* compile lines
          SEABIOS_UPSTREAM_URL="rose-dev@rosecompiler1.llnl.gov:rose/c/xen/seabios.git" \
          SEABIOS_UPSTREAM_TAG="master" \
          ROSE_IPXE_GIT_URL="rose-dev@rosecompiler1.llnl.gov:rose/c/xen/ipxe.git" \
              make dist -j1 V=1 2>&1 | tee output-make-gcc.txt || exit 1
          if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            echo "[FATAL] GCC compilation failed. Terminating..."
            exit 1
          fi
          
          # (2) Replace Make Entering/Leaving directory changes with pushd/popd
          cat output-make-gcc.txt | \
              sed "s/^make.*Entering directory \`\(.*\)'$/pushd \1/" | \
              sed "s/^make.*Leaving directory.*/popd/" | \
              sed 's/^make.*//' \
          > make-handle_directory_changes.txt || exit 1
          
          # (3) Replace gcc, cc, libtool cc compile lines with ${ROSE_CC} variable
          cat make-handle_directory_changes.txt | \
              sed 's/^cc/\${ROSE_CC}/' | \
              sed 's/^gcc/\${ROSE_CC}/' | \
              sed 's/^libtool.*--mode=compile.*--tag=CC cc/\${ROSE_CC}/' \
          > make-rose-0.txt || exit 1
 
          # (4) Save replay commands: ROSE_CC, pushd, popd
          cat make-rose-0.txt | \
              grep "^\${ROSE_CC}\|^pushd\|^popd" \
          > make-rose.txt || exit 1

          # 
          cat <<EOF | cat - make-rose.txt > make-rose.sh
#!/bin/bash -x
which \${ROSE_CC}
echo \$LD_LIBRARY_PATH
echo \$PATH
EOF

          # (5) Remove -Werror commandline options
          perl \
            -pi.bak \
            -e 's/-Werror//g' \
            "make-rose.sh" || exit 1

          # Debug
if test -n "${ROSE_DEBUG:+yes}"; then
cat <<EOF | cat - make-rose.sh > make-rose-debug.sh
function rose_trap_handler()
{
    CMD="\$0"                 # equals to my script name
    LASTLINE="\$1"            # argument 1: line of command
    LASTERR="\$2"             # argument 2: error code of last command
    echo "[DEBUG] \${CMD}: line \${LASTLINE}: exit status of last command: \${LASTERR}"
    echo "[DEBUG] ROSE P=\$(cat "${application_abs_srcdir}/rose-passes.txt" | wc -l) F=\$(cat "${application_abs_srcdir}/rose-failures.txt" | wc -l)"
}

# trap all simple commands
trap 'rose_trap_handler \${LINENO} \$?' ERR DEBUG
EOF
fi

          # (6) Execute ROSE commandlines; $ROSE_CC must be set
          chmod +x make-rose.sh
          time ./make-rose${ROSE_DEBUG:+-debug}.sh || exit 1

# Extract results from Sqlite database and save to files:
#
#     rose-passes.txt
#     rose-failures.txt
#
sqlite3 rose-results.db > rose-passes.txt <<SQL
SELECT filename FROM results WHERE passed=1;
SQL

sqlite3 rose-results.db > rose-failures.txt <<SQL
SELECT filename FROM results WHERE passed=0;
SQL

  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
