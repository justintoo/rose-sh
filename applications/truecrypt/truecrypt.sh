: ${TRUECRYPT_DEPENDENCIES:=nasm}
#: ${TRUECRYPT_DEPENDENCIES:=nasm wxwidgets}
# libfuse requires root permission to install: /bin/install: cannot remove ‘/sbin/mount.fuse’: Permission denied
: ${TRUECRYPT_CONFIGURE_OPTIONS:=
  }

#-------------------------------------------------------------------------------
download_truecrypt()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_truecrypt()
#-------------------------------------------------------------------------------
{
  install_deps ${TRUECRYPT_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_truecrypt()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_truecrypt__rose()
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
configure_truecrypt__gcc()
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
compile_truecrypt()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
    wget "http://prdownloads.sourceforge.net/wxwindows/wxWidgets-2.8.12.tar.gz" || fail "Unable to download wxWidgets"
    tar xzvf wxWidgets-2.8.12.tar.gz
    make WX_ROOT="$(pwd)/wxWidgets-2.8.12" wxbuild || fail "An error occurred while building wxWidgets"

    # trying to find fuse.h
    SYSTEM_CC="${CC}" \
    SYSTEM_CXX="${CXX}" \
    CC="${ROSE_CC}" \
    CXX="${ROSE_CXX}" \
    PKCS11_INC="$(pwd)/PKCS-Headers" \
      /usr/bin/time --format=%E make --keep-going -j${parallelism} VERBOSE=1 WXSTATIC=1 || fail "An error occurred while building TrueCrypt"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
