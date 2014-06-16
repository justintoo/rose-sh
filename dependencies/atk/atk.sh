: ${ATK_DEPENDENCIES:=glib intltool}
: ${ATK_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${ATK_TARBALL:="atk-2.10.0.tar.xz"}
: ${ATK_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/atk-1.0/atk/atk.h"}

#-------------------------------------------------------------------------------
install_atk()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${ATK_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${ATK_INSTALLED_FILE}" ]; then
      rm -rf "./atk"  || fail "Unable to remove old application workspace"
      mkdir -p "atk"  || fail "Unable to create application workspace"
      cd "atk/"       || fail "Unable to change into the application workspace"

      download_tarball "${ATK_TARBALL}"        || fail "Unable to download application tarball"
      unxz "${ATK_TARBALL}"                   || fail "Unable to unpack application tarball"
      tar xvf "${ATK_TARBALL%.xz}"            || fail "Unable to unpack application tarball"
      cd "$(basename ${ATK_TARBALL%.tar.xz})" || fail "Unable to change into application source directory"

      ./configure ${ATK_CONFIGURE_OPTIONS} || fail "Unable to configure application"

      make -j${parallelism}         || fail "An error occurred during application compilation"
      make -j${parallelism} install || fail "An error occurred during application installation"
  else
      info "[SKIP] atk is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
