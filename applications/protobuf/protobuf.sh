: ${PROTOBUF_DEPENDENCIES:=}
: ${PROTOBUF_CONFIGURE_OPTIONS:=
  }

#-------------------------------------------------------------------------------
download_protobuf()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_protobuf()
#-------------------------------------------------------------------------------
{
  install_deps ${PROTOBUF_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_protobuf()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_protobuf__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${PROTOBUF_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
              #CC="${ROSE_CC}"
              #CXX="${ROSE_CXX}"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_protobuf__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${CC}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${PROTOBUF_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_protobuf()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      # Fails to compile correctly with -fPIC, so libprotobuf.so.8 is empty
      # and therefore, linking fails
      make CXX=g++ descriptor.lo -C src/
      if [ $? -ne 0 ]; then
        fail "GCC compilation failed"
      fi

      # Skip unit tests due to `protoc` segmentation fault
      make CC="${ROSE_CC}" CXX="${ROSE_CXX}" protoc_outputs= -j${parallelism}
      if [ $? -ne 0 ]; then
        fail "An error occurred during application compilation"
      fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

