: ${LULESH_DEPENDENCIES:=}

#-------------------------------------------------------------------------------
download_lulesh()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      wget "https://codesign.llnl.gov/lulesh/lulesh2.0.3.tgz" || exit 1
      tar zxf lulesh2.0.3.tgz || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_lulesh()
#-------------------------------------------------------------------------------
{
  install_deps ${LULESH_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_lulesh()
#-------------------------------------------------------------------------------
{
  info "Patching application"

  #-----------------------------------------------------------------------------
  # src/gnutls.c
  #-----------------------------------------------------------------------------
  info "[Patch] Replacing CXX compiler with environment varaible \$MY_CXX"

  f="Makefile"
  echo "Hacking file '$f' to change \$(MPICXX) to \$(MY_CXX)..."
  mv $f $f-old
  cat "${f}-old" | sed 's/\$(MPICXX)/\$(MY_CXX)/g' > "$f" 

}

#-------------------------------------------------------------------------------
configure_lulesh__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring LULESH for ROSE"
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      export MY_CXX="${ROSE_CXX} -DUSE_MPI=0"
      echo ${ROSE_CXX}
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_lulesh__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring LULESH for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      export MY_CXX="${CXX} -DUSE_MPI=0"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_lulesh()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make || exit 1
  set +x
}