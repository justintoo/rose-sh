: ${GDK_PIXBUF_DEPENDENCIES:=glib jasper libjpeg libpng tiff}
: ${GDK_PIXBUF_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --with-libjasper
    --without-gdiplus
    --with-libpng
    --with-libjpeg
    --with-libtiff
  }
: ${GDK_PIXBUF_TARBALL:="gdk-pixbuf-2.30.0.tar.xz"}
: ${GDK_PIXBUF_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gdk-pixbuf-2.0/gdk-pixbuf/gdk-pixbuf.h"}

#-------------------------------------------------------------------------------
install_gdk_pixbuf()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GDK_PIXBUF_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GDK_PIXBUF_INSTALLED_FILE}" ]; then
      rm -rf "./gdk_pixbuf"  || fail "Unable to remove old application workspace"
      mkdir -p "gdk_pixbuf"  || fail "Unable to create application workspace"
      cd "gdk_pixbuf/"       || fail "Unable to change into the application workspace"

      download_tarball "${GDK_PIXBUF_TARBALL}"        || fail "Unable to download application tarball"
      unxz "${GDK_PIXBUF_TARBALL}"                    || fail "Unable to unpack application tarball"
      tar xvf "${GDK_PIXBUF_TARBALL%.xz}"             || fail "Unable to unpack application tarball"
      cd "$(basename ${GDK_PIXBUF_TARBALL%.tar.xz})"  || fail "Unable to change into application source directory"

      LDFLAGS="$LDFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS" \
          ./configure \
              ${GDK_PIXBUF_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] gdk_pixbuf is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
