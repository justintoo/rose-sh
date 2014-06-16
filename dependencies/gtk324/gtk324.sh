: ${GTK324_DEPENDENCIES:=glib atk pango cairo gdk_pixbuf}
: ${GTK324_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --disable-cups
    --disable-papi
    --with-x
    --enable-x11-backend
    --enable-broadway-backend
  }
: ${GTK324_TARBALL:="gtk+-3.2.4.tar.xz"}
: ${GTK324_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/gtk-3.0/gtk/gtk.h"}

#-------------------------------------------------------------------------------
install_gtk324()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${GTK324_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${GTK324_INSTALLED_FILE}" ]; then
      rm -rf "./gtk324"  || fail "Unable to remove application workspace"
      mkdir -p "gtk324"  || fail "Unable to create application workspace"
      cd "gtk324/"       || fail "Unable to change into the application workspace"

      download_tarball "${GTK324_TARBALL}"       || fail "Unable to download application tarball"
      unxz "${GTK324_TARBALL}"                   || fail "Unable to unpack application tarball"
      tar xvf "${GTK324_TARBALL%.xz}"            || fail "Unable to unpack application tarball"
      cd "$(basename ${GTK324_TARBALL%.tar.xz})" || fail "Unable to change into application source directory"

      ./configure ${GTK324_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] gtk324 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
