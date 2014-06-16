# http://cgit.freedesktop.org/dbus/dbus/?h=dbus-1.8

# Interferes with applications/dbus
#: ${DBUS_DEPENDENCIES:=expat}
: ${DBUS_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --disable-tests
    --disable-selinux
  }
: ${DBUS_TARBALL:="dbus-1.8.0.tar.gz"}
: ${DBUS_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/bin/dbus-launch"}

#-------------------------------------------------------------------------------
install_dbus()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${DBUS_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${DBUS_INSTALLED_FILE}" ]; then
      rm -rf "./dbus"                           || fail "Unable to remove application workspace"
      mkdir -p "dbus"                           || fail "Unable to create application workspace"
      cd "dbus/"                                || fail "Unable to change into the application workspace"

      download_tarball "${DBUS_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${DBUS_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${DBUS_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      LDFLAGS="$LDFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="-Wno-error $CFLAGS" \
        ./autogen.sh ${DBUS_CONFIGURE_OPTIONS}  || fail "An error occurred during application autotools bootstrapping"

      #./configure ${DBUS_CONFIGURE_OPTIONS}   || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] dbus is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
