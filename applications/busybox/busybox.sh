: ${BUSYBOX_DEPENDENCIES:=}
: ${BUSYBOX_CONFIGURE_OPTIONS=}

#-------------------------------------------------------------------------------
download_busybox()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
  set +x
}

#-------------------------------------------------------------------------------
install_deps_busybox()
#-------------------------------------------------------------------------------
{
  install_deps ${BUSYBOX_DEPENDENCIES} || exit 1
}

#-------------------------------------------------------------------------------
patch_busybox()
#-------------------------------------------------------------------------------
{
  info "Patching"
}

#-------------------------------------------------------------------------------
configure_busybox__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  set -x
      make defconfig || exit 1
      export CC="${ROSE_CC} -rose:markGeneratedFiles"
  set +x
}

#-------------------------------------------------------------------------------
configure_busybox__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CC}'"

  set -x
      make defconfig || exit 1
      export CC="${CC}"
  set +x
}

#-------------------------------------------------------------------------------
compile_busybox()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make V=1 install -j${parallelism} \
          CC="${CC}" \
          \
              CONFIG_PREFIX="$(pwd)/installation" \
              CONFIG_PID_FILE_PATH="$(pwd)/installation/var/run" \
              CONFIG_BUSYBOX_EXEC_PATH="$(pwd)/installation/bin/busybox" \
              CONFIG_EXTRA_CFLAGS="$CFLAGS" \
              CONFIG_EXTRA_LDFLAGS="$LDFLAGS" \
          \
          || exit 1
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
