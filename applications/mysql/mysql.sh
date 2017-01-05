: ${MYSQL_DEPENDENCIES:=ncurses}
: ${MYSQL_CONFIGURE_OPTIONS:=
  }

#-------------------------------------------------------------------------------
download_mysql()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"

  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/" || exit 1
      wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
  set +x
}

#-------------------------------------------------------------------------------
install_deps_mysql()
#-------------------------------------------------------------------------------
{
  install_deps ${MYSQL_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_mysql()
#-------------------------------------------------------------------------------
{
  info "Patching not required"
}

#-------------------------------------------------------------------------------
configure_mysql__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring application for ROSE compiler='${ROSE_CC}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      CC="${ROSE_CC}" \
      CXX="${ROSE_CXX}" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS"  \
      LDFLAGS="$LDFLAGS"  \
      cmake . -DDOWNLOAD_BOOST=1 -DWITH_BOOST="$(pwd)" || fail "An error occurred during CMake bootstrapping"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_mysql__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring application for default compiler='${CXX}'"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      fatal "Not implemented yet"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_mysql()
#-------------------------------------------------------------------------------
{
  info "Compiling application"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
      make CXX="${ROSE_CXX}" -j${parallelism}         || fail "An error occurred during application compilation"
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}
