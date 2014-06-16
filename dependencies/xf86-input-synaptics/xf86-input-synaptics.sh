# Homepage: http://cgit.freedesktop.org/xorg/driver/xf86-input-synaptics/

: ${XF86_INPUT_SYNAPTICS_DEPENDENCIES:=xorg_util_macros xorg_server}
: ${XF86_INPUT_SYNAPTICS_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
    --enable-static
  }
: ${XF86_INPUT_SYNAPTICS_TARBALL:="xf86-input-synaptics-1.7.6.tar.gz"}
: ${XF86_INPUT_SYNAPTICS_INSTALLED_XF86_INPUT_SYNAPTICS:="${ROSE_SH_DEPS_PREFIX}/bin/xf86_input_synaptics"}

#-------------------------------------------------------------------------------
install_xf86_input_synaptics()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${XF86_INPUT_SYNAPTICS_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${XF86_INPUT_SYNAPTICS_INSTALLED_XF86_INPUT_SYNAPTICS}" ]; then
      rm -rf "./xf86_input_synaptics"                           || fail "Unable to remove old application workspace"
      mkdir -p "xf86_input_synaptics"                           || fail "Unable to create application workspace"
      cd "xf86_input_synaptics/"                                || fail "Unable to change into the application workspace"

      download_tarball "${XF86_INPUT_SYNAPTICS_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${XF86_INPUT_SYNAPTICS_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "$(basename ${XF86_INPUT_SYNAPTICS_TARBALL%.tar.gz})"  || fail "Unable to change into application source directory"

      ACLOCAL_PATH="${ROSE_SH_DEPS_PREFIX}/share/aclocal:${ACLOCAL_PATH}" \
          ./autogen.sh                                          || fail "Unable to bootstrap application"
      ./configure ${XF86_INPUT_SYNAPTICS_CONFIGURE_OPTIONS}     || fail "Unable to configure application"

      make -j${parallelism}                     || fail "An error occurred during application compilation"
      make -j${parallelism} install             || fail "An error occurred during application installation"
  else
      info "[SKIP] xf86_input_synaptics is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
