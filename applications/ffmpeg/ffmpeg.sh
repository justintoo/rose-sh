: ${FFMPEG_DEPENDENCIES:=zlib openssl}

#-------------------------------------------------------------------------------
download_ffmpeg()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_ffmpeg()
#-------------------------------------------------------------------------------
{
  install_deps ${FFMPEG_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_ffmpeg()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_ffmpeg__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      ./configure \
          --prefix="$(pwd)/install_tree" \
          --disable-yasm \
          \
              --enable-shared \
              --disable-doc \
              --enable-pthreads \
              --disable-w32threads \
              --disable-os2threads \
              --enable-zlib \
              --enable-openssl \
              --disable-asm \
              --enable-pic \
              --extra-cflags="$CFLAGS" \
              --extra-ldflags="$LDFLAGS" \
          \
          || exit 1

      export CC="${ROSE_CC} -rose:unparse_in_same_directory_as_input_file"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_ffmpeg__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      ./configure \
          --prefix="$(pwd)/install_tree" \
          --disable-yasm \
          \
              --enable-shared \
              --disable-doc \
              --enable-pthreads \
              --disable-w32threads \
              --disable-os2threads \
              --enable-zlib \
              --enable-openssl \
              --disable-asm \
              --enable-pic \
              --extra-cflags="$CFLAGS" \
              --extra-ldflags="$LDFLAGS" \
          \
          || exit 1

      export CC="${CC}"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_ffmpeg()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  # TOO1 (2/6/2014) We'll just always enable VERBOSE output
  set -x
      make V=1 CC="${CC}" -j${parallelism}          || exit 1
      make V=1 CC="${CC}" -j${parallelism} install  || exit 1
  set +x
}
