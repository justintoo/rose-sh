#Must be built with specially built rose:
#
#export TOOLCHAIN_ROOT=/tmp/leek2/rose-sh/workspace/itron/phase_1/itron-src/toolchain;../configure --with-boost=/nfs/casc/overture/ROSE/opt/rhel7/x86_64/boost/1_57_0/gcc/4.8.3 --prefix=/tmp/leek2/itron_rose_inst --with-alternate_backend_C_compiler="${TOOLCHAIN_ROOT}/bin/armv7l-timesys-linux-uclibcgnueabi-gcc --sysroot=${TOOLCHAIN_ROOT}/" --with-alternate_backend_Cxx_compiler="${TOOLCHAIN_ROOT}/bin/armv7l-timesys-linux-uclibcgnueabi-g++ --sysroot=${TOOLCHAIN_ROOT}/"
#


: ${ITRON_DEPENDENCIES:=}

#-------------------------------------------------------------------------------
download_itron()
#-------------------------------------------------------------------------------
{
  info "Downloading source code"
#git clone rose-dev@rosecompiler1.llnl.gov:3rdparty/cxx/itron.git
  set -x
      clone_repository "${application}" "${application}-src" || exit 1
      cd "${application}-src/toolchain" || exit 1
      export TOOLCHAIN_ROOT=$PWD
      export PKG_CONFIG_PATH=$TOOLCHAIN_ROOT/lib/pkgconfig
      export PATH=TOOLCHAIN_ROOT/bin:$PATH
      cd ..
  set +x
}

#-------------------------------------------------------------------------------
install_deps_itron()
#-------------------------------------------------------------------------------
#The only dependencies is the toolchain, which needs to be patched so it's done there.
{
  install_deps ${ITRON_DEPENDENCIES} || fail "Could not install dependencies"
}

#-------------------------------------------------------------------------------
patch_itron()
#-------------------------------------------------------------------------------
{
  info "Patching toolchain"

  #-----------------------------------------------------------------------------
  # Patch libItronBase.la
  #-----------------------------------------------------------------------------
  info "[Patch] fix paths in libItronBase.la"
  echo $PWD

  f=$TOOLCHAIN_ROOT/lib/libItronBase.la
  echo "Hacking file '$f' to change hardcoded toolchain root to \$TOOLCHAIN_ROOT"
  mv $f $f-orig
  cat "${f}-orig" | sed 's@/home/riva/RIVA_OPENWAY_SR_2-1/factory-20140707/build_armv7l-timesys-linux-uclibcgnueabi/toolchain@\${TOOLCHAIN_ROOT}@g' > "$f" 
  mv $f $f-orig2
  cat "${f}-orig2" | sed 's@/home/riva/RIVA_OPENWAY_SR_2-1/factory-20140707@\${TOOLCHAIN_ROOT}@g' > "$f" 

  #-----------------------------------------------------------------------------
  # Patch libLoggingApplication.la
  #-----------------------------------------------------------------------------
  info "[Patch] fix paths in libLoggingApplicationBlock.la"

  f=$TOOLCHAIN_ROOT/lib/libLoggingApplicationBlock.la
  echo "Hacking file '$f' to change hardcoded toolchain root to \$TOOLCHAIN_ROOT"
  mv $f $f-orig
  cat "${f}-orig" | sed 's@/home/riva/RIVA_OPENWAY_SR_2-1/factory-20140707/build_armv7l-timesys-linux-uclibcgnueabi/toolchain@\${TOOLCHAIN_ROOT}@g' > "$f" 
  mv $f $f-orig2
  cat "${f}-orig2" | sed 's@/home/riva/RIVA_OPENWAY_SR_2-1/factory-20140707@\${TOOLCHAIN_ROOT}@g' > "$f" 

  #-----------------------------------------------------------------------------
  # Patch dbus-1.pc with correct path
  #-----------------------------------------------------------------------------
  info "[Patch] fix paths in dbus-1.pc"

  f=$PKG_CONFIG_PATH/dbus-1.pc
  echo "Hacking file '$f' to change hardcoded toolchain root to $TOOLCHAIN_ROOT"
  mv $f $f-orig
  cat "${f}-orig" | sed "s@/home/riva/RIVA_OPENWAY_SR_2-1/factory-20140707/build_armv7l-timesys-linux-uclibcgnueabi/toolchain@$TOOLCHAIN_ROOT@g" > "$f" 
  mv $f $f-orig2
  cat "${f}-orig2" | sed "s@/home/riva/RIVA_OPENWAY_SR_2-1/factory-20140707@$TOOLCHAIN_ROOT@g" > "$f" 

}

#-------------------------------------------------------------------------------
configure_itron__rose()
#-------------------------------------------------------------------------------
{
  info "Configuring Itron for ROSE"
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  info "Configuring Itron for default compiler=armv7l-timesys-linux-uclibcgnueabi-g++"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  info "Configuration dlmsd for armv7l-timesys-linux-uclibcgnueabi-g++"
  echo $PWD
  echo "---------------------------------------------"
  cd dlmsd
  ./configure --target=armv7l-timesys-linux-uclibcgnueabi --host=armv7l-timesys-linux-uclibcgnueabi --build=x86_64-linux-gnu --prefix=${TOOLCHAIN_ROOT}/usr --exec-prefix=${TOOLCHAIN_ROOT}/usr --bindir=${TOOLCHAIN_ROOT}/usr/bin --sbindir=${TOOLCHAIN_ROOT}/usr/sbin --libdir=${TOOLCHAIN_ROOT}/usr/lib --libexecdir=${TOOLCHAIN_ROOT}/usr/lib --sysconfdir=${TOOLCHAIN_ROOT}/etc --datadir=${TOOLCHAIN_ROOT}/share --localstatedir=${TOOLCHAIN_ROOT}/var --mandir=${TOOLCHAIN_ROOT}/usr/share/man --infodir=${TOOLCHAIN_ROOT}/usr/share/info --includedir=${TOOLCHAIN_ROOT}/usr/include CC="{ROSE_CC} --sysroot=${TOOLCHAIN_ROOT}/" CXX="${ROSE_CXX} --sysroot=${TOOLCHAIN_ROOT}/" || fail "An error occurred during dlmsd configuration"
  cd ..

  info "Configuration cosemd for armv7l-timesys-linux-uclibcgnueabi-g++"
  cd cosemd
  ./configure --target=armv7l-timesys-linux-uclibcgnueabi --host=armv7l-timesys-linux-uclibcgnueabi --build=x86_64-linux-gnu --prefix=${TOOLCHAIN_ROOT}/usr --exec-prefix=${TOOLCHAIN_ROOT}/usr --bindir=${TOOLCHAIN_ROOT}/usr/bin --sbindir=${TOOLCHAIN_ROOT}/usr/sbin --libdir=${TOOLCHAIN_ROOT}/usr/lib --libexecdir=${TOOLCHAIN_ROOT}/usr/lib --sysconfdir=${TOOLCHAIN_ROOT}/etc --datadir=${TOOLCHAIN_ROOT}/share --localstatedir=${TOOLCHAIN_ROOT}/var --mandir=${TOOLCHAIN_ROOT}/usr/share/man --infodir=${TOOLCHAIN_ROOT}/usr/share/info --includedir=${TOOLCHAIN_ROOT}/usr/include CC="{ROSE_CC} --sysroot=${TOOLCHAIN_ROOT}/" CXX="${ROSE_CXX} --sysroot=${TOOLCHAIN_ROOT}/" || fail "An error occurred during cosemd configuration"
  cd ..

  info "Configuration cosemd for armv7l-timesys-linux-uclibcgnueabi-g++"
  cd eismd
  ./configure --target=armv7l-timesys-linux-uclibcgnueabi --host=armv7l-timesys-linux-uclibcgnueabi --build=x86_64-linux-gnu --prefix=${TOOLCHAIN_ROOT}/usr --exec-prefix=${TOOLCHAIN_ROOT}/usr --bindir=${TOOLCHAIN_ROOT}/usr/bin --sbindir=${TOOLCHAIN_ROOT}/usr/sbin --libdir=${TOOLCHAIN_ROOT}/usr/lib --libexecdir=${TOOLCHAIN_ROOT}/usr/lib --sysconfdir=${TOOLCHAIN_ROOT}/etc --datadir=${TOOLCHAIN_ROOT}/share --localstatedir=${TOOLCHAIN_ROOT}/var --mandir=${TOOLCHAIN_ROOT}/usr/share/man --infodir=${TOOLCHAIN_ROOT}/usr/share/info --includedir=${TOOLCHAIN_ROOT}/usr/include --disable-shared CC="{ROSE_CC}--sysroot=${TOOLCHAIN_ROOT}/" CXX="${ROSE_CXX} --sysroot=${TOOLCHAIN_ROOT}/" || fail "An error occurred during eismd configuration"
  cd ..
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
configure_itron__gcc()
#-------------------------------------------------------------------------------
{
  info "Configuring Itron for default compiler=armv7l-timesys-linux-uclibcgnueabi-g++"

  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  info "Configuration dlmsd for armv7l-timesys-linux-uclibcgnueabi-g++"
  cd dlmsd
  ./configure --target=armv7l-timesys-linux-uclibcgnueabi --host=armv7l-timesys-linux-uclibcgnueabi --build=x86_64-linux-gnu --prefix=${TOOLCHAIN_ROOT}/usr --exec-prefix=${TOOLCHAIN_ROOT}/usr --bindir=${TOOLCHAIN_ROOT}/usr/bin --sbindir=${TOOLCHAIN_ROOT}/usr/sbin --libdir=${TOOLCHAIN_ROOT}/usr/lib --libexecdir=${TOOLCHAIN_ROOT}/usr/lib --sysconfdir=${TOOLCHAIN_ROOT}/etc --datadir=${TOOLCHAIN_ROOT}/share --localstatedir=${TOOLCHAIN_ROOT}/var --mandir=${TOOLCHAIN_ROOT}/usr/share/man --infodir=${TOOLCHAIN_ROOT}/usr/share/info --includedir=${TOOLCHAIN_ROOT}/usr/include CC="${TOOLCHAIN_ROOT}/bin/armv7l-timesys-linux-uclibcgnueabi-gcc --sysroot=${TOOLCHAIN_ROOT}/" CXX="${TOOLCHAIN_ROOT}/bin/armv7l-timesys-linux-uclibcgnueabi-g++ --sysroot=${TOOLCHAIN_ROOT}/" || fail "An error occurred during dlmsd configuration"
  cd ..

  info "Configuration cosemd for armv7l-timesys-linux-uclibcgnueabi-g++"
  cd cosemd
  ./configure --target=armv7l-timesys-linux-uclibcgnueabi --host=armv7l-timesys-linux-uclibcgnueabi --build=x86_64-linux-gnu --prefix=${TOOLCHAIN_ROOT}/usr --exec-prefix=${TOOLCHAIN_ROOT}/usr --bindir=${TOOLCHAIN_ROOT}/usr/bin --sbindir=${TOOLCHAIN_ROOT}/usr/sbin --libdir=${TOOLCHAIN_ROOT}/usr/lib --libexecdir=${TOOLCHAIN_ROOT}/usr/lib --sysconfdir=${TOOLCHAIN_ROOT}/etc --datadir=${TOOLCHAIN_ROOT}/share --localstatedir=${TOOLCHAIN_ROOT}/var --mandir=${TOOLCHAIN_ROOT}/usr/share/man --infodir=${TOOLCHAIN_ROOT}/usr/share/info --includedir=${TOOLCHAIN_ROOT}/usr/include CC="${TOOLCHAIN_ROOT}/bin/armv7l-timesys-linux-uclibcgnueabi-gcc --sysroot=${TOOLCHAIN_ROOT}/" CXX="${TOOLCHAIN_ROOT}/bin/armv7l-timesys-linux-uclibcgnueabi-g++ --sysroot=${TOOLCHAIN_ROOT}/" || fail "An error occurred during cosemd configuration"
  cd ..

  info "Configuration cosemd for armv7l-timesys-linux-uclibcgnueabi-g++"
  cd eismd
  ./configure --target=armv7l-timesys-linux-uclibcgnueabi --host=armv7l-timesys-linux-uclibcgnueabi --build=x86_64-linux-gnu --prefix=${TOOLCHAIN_ROOT}/usr --exec-prefix=${TOOLCHAIN_ROOT}/usr --bindir=${TOOLCHAIN_ROOT}/usr/bin --sbindir=${TOOLCHAIN_ROOT}/usr/sbin --libdir=${TOOLCHAIN_ROOT}/usr/lib --libexecdir=${TOOLCHAIN_ROOT}/usr/lib --sysconfdir=${TOOLCHAIN_ROOT}/etc --datadir=${TOOLCHAIN_ROOT}/share --localstatedir=${TOOLCHAIN_ROOT}/var --mandir=${TOOLCHAIN_ROOT}/usr/share/man --infodir=${TOOLCHAIN_ROOT}/usr/share/info --includedir=${TOOLCHAIN_ROOT}/usr/include --disable-shared CC="${TOOLCHAIN_ROOT}/bin/armv7l-timesys-linux-uclibcgnueabi-gcc --sysroot=${TOOLCHAIN_ROOT}/" CXX="${TOOLCHAIN_ROOT}/bin/armv7l-timesys-linux-uclibcgnueabi-g++ --sysroot=${TOOLCHAIN_ROOT}" || fail "An error occurred during eismd configuration"
  cd ..
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------
}

#-------------------------------------------------------------------------------
compile_itron()
#-------------------------------------------------------------------------------
{
  info "Compiling dlmsd"

  set -x
      cd dlmsd
      make || exit 1
      cd ..

      cd cosemd
      make || exit 1
      cd ..

      cd eismd
      make || exit 1
      cd ..

  set +x
}
