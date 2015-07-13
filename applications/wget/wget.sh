: ${WGET_DEPENDENCIES:=}

#-------------------------------------------------------------------------------
download_wget()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
      # TOO1 (07/10/2015): Use older version since 1.16.3 does not pass
      git checkout v1.14 || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_wget()
#-------------------------------------------------------------------------------
{
  install_deps ${WGET_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_wget()
#-------------------------------------------------------------------------------
{
  info "Patching application"

  #-----------------------------------------------------------------------------
  # src/gnutls.c
  #-----------------------------------------------------------------------------
  info "[Patch] Replacing \"GNUTLS_TLS1_2\" by \"GNUTLS_TLS1_1\" so it will compile on our operating systems"

  f="src/gnutls.c"
  echo "Hacking file '$f' to change 'GNUTLS_TLS1_2' to 'GNUTLS_TLS1_1'..."
  mv $f $f-old
  cat "${f}-old" | sed 's/GNUTLS_TLS1_2/GNUTLS_TLS1_1/g' > "$f" 

  #-----------------------------------------------------------------------------
  # lib/utimens.c
  #-----------------------------------------------------------------------------
  info "[Patch] Change include to be local instead of system <sys/stat.h> to \"sys/stat.h\""

  cp lib/utimens.c lib/utimens.c-old
  cat lib/utimens.c-old | sed 's/#include <sys\/stat.h>/#include "sys\/stat.h"/g' > lib/utimens.c
}

#-------------------------------------------------------------------------------
configure_wget__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${ROSE_CC} -rose:C89_only" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_wget__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${CC}" \
          ./configure --prefix="$(pwd)/install_tree" || exit 1

      export CC="${CC}"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_wget()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  set -x
      make -j${parallelism}  || exit 1
  set +x
}
