: ${GTK224_DEPENDENCIES:=glib atk pango cairo gdk_pixbuf}
: ${GTK224_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --disable-cups
    --disable-papi
    --with-x
    --enable-x11-backend
    --enable-broadway-backend
  }
: ${GTK224_TARBALL:="gtk+-2.24.21.tar.xz"}
: ${GTK224_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gtk-2.0/gtk/gtk.h"}

#-------------------------------------------------------------------------------
install_gtk224()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GTK224_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GTK224_INSTALLED_FILE}" ]; then
      rm -rf "./gtk224"  || fail "Unable to remove application workspace"
      mkdir -p "gtk224"  || fail "Unable to create application workspace"
      cd "gtk224/"       || fail "Unable to change into the application workspace"

      download_tarball "${GTK224_TARBALL}"       || fail "Unable to download application tarball"
      unxz "${GTK224_TARBALL}"                   || fail "Unable to unpack application tarball"
      tar xvf "${GTK224_TARBALL%.xz}"            || fail "Unable to unpack application tarball"
      cd "$(basename ${GTK224_TARBALL%.tar.xz})" || fail "Unable to change into application source directory"

      ./configure ${GTK224_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] gtk224 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
