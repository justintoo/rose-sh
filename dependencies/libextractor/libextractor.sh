# TODO: Requires libtool (ltdl.h and libltdlc)

: ${LIBEXTRACTOR_DEPENDENCIES:=glib bzip2 libxml2 zlib}
: ${LIBEXTRACTOR_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --disable-gnome
    --disable-ffmpeg
    --disable-gtktest
    --disable-gsf
  }
: ${LIBEXTRACTOR_TARBALL:="libextractor-1.1.tar.gz"}
: ${LIBEXTRACTOR_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/extractor.h"}

#-------------------------------------------------------------------------------
install_libextractor()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${LIBEXTRACTOR_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${LIBEXTRACTOR_INSTALLED_FILE}" ]; then
      rm -rf "./libextractor"  || fail "Unable to remove old application workspace"
      mkdir -p "libextractor"  || fail "Unable to create application workspace"
      cd "libextractor/"       || fail "Unable to change into the application workspace"

      download_tarball "${LIBEXTRACTOR_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${LIBEXTRACTOR_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${LIBEXTRACTOR_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      LDFLAGS="$LDFLAGS"    \
      CPPFLAGS="$CPPFLAGS"  \
      CFLAGS="$CFLAGS"      \
          ./configure ${LIBEXTRACTOR_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make PLUGIN_RPM= -j${parallelism}           || fail "An error occurred during application compilation"
      make PLUGIN_RPM= -j${parallelism} install   || fail "An error occurred during application installation"
  else
      info "[SKIP] libextractor is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
