: ${IMAGE_MAGICK_DEPENDENCIES:=libjpeg libpng tiff lcms libtool liblqr freetype fontconfig glib bzip2}
: ${IMAGE_MAGICK_CONFIGURE_OPTIONS:=
    --without-lcms
    --without-perl
    --with-lcms2
    --without-gslib
    --without-jbig
    --without-x
    --without-lzma
    --disable-opencl
    --without-autotrace
    --without-djvu
    --without-fftw
    --without-fpx
    --without-gvc
    --with-fontconfig
    --with-freetype
    --without-dps
    --without-openexr
    --without-pango
    --with-png
    --with-tiff
    --without-webp
    --without-wmf
    --with-xml
    --without-mupdf
    --without-rsvg
    --with-magick-plus-plus
    --with-gs-font-dir="${ROSE_SH_DEPS_PREFIX}/share/ghostscript/fonts"
    --disable-openmp
  }

#-------------------------------------------------------------------------------
download_image_magick()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_image_magick()
#-------------------------------------------------------------------------------
{
  install_deps ${IMAGE_MAGICK_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_image_magick()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_image_magick__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${ROSE_CC}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
          ./configure \
              --prefix="$(pwd)/install_tree" \
              ${IMAGE_MAGICK_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_image_magick__gcc()
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
              ${IMAGE_MAGICK_CONFIGURE_OPTIONS} || fail "An error occurred during application configuration"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_image_magick()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
