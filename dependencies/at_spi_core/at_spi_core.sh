: ${AT_SPI_CORE_DEPENDENCIES:=glib atk dbus x11_r682}
: ${AT_SPI_CORE_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --disable-x11
  }
: ${AT_SPI_CORE_TARBALL:="at-spi2-core-2.10.1.tar.xz"}
: ${AT_SPI_CORE_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/at-spi-2.0/atspi/atspi.h"}

#-------------------------------------------------------------------------------
install_at_spi_core()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${AT_SPI_CORE_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${AT_SPI_CORE_INSTALLED_FILE}" ]; then
      rm -rf "./at_spi_core"                            || fail "Unable to remove application workspace"
      mkdir -p "at_spi_core"                            || fail "Unable to create application workspace"
      cd "at_spi_core/"                                 || fail "Unable to change into the application workspace"

      download_tarball "${AT_SPI_CORE_TARBALL}"         || fail "Unable to download application tarball"
      unxz "${AT_SPI_CORE_TARBALL}"                     || fail "Unable to unpack application tarball"
      tar xvf "${AT_SPI_CORE_TARBALL%.xz}"              || fail "Unable to unpack application tarball"
      cd "$(basename ${AT_SPI_CORE_TARBALL%.tar.xz})"   || fail "Unable to change into application source directory"

      ./configure ${AT_SPI_CORE_CONFIGURE_OPTIONS}      || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] at_spi_core is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
