# http://xorg.freedesktop.org/releases/X11R6.8.2/

: ${x11_r682_DEPENDENCIES:=fontconfig freetype21 flex}
: ${x11_r682_CONFIGURE_OPTIONS:=
    --prefix="${ROSE_SH_DEPS_PREFIX}"
    --libdir="${ROSE_SH_DEPS_LIBDIR}"
  }
: ${x11_r682_TARBALL:="X11R6.8.2-src.tar.gz"}
: ${x11_r682_INSTALLED_FILE:="${ROSE_SH_DEPS_PREFIX}/include/x11_r682/x11_r682.h"}

#-------------------------------------------------------------------------------
install_x11_r682()
#-------------------------------------------------------------------------------
{
  info "Installing application"

  #-----------------------------------------------------------------------------
  rosesh__install_dep_setup || exit 1
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  # Dependencies
  #-----------------------------------------------------------------------------
  install_deps ${x11_r682_DEPENDENCIES} || exit 1

  #-----------------------------------------------------------------------------
  # Installation
  #-----------------------------------------------------------------------------
  set -x
  #-----------------------------------------------------------------------------
  if [ ! -f "${x11_r682_INSTALLED_FILE}" ]; then
      rm -rf "./x11_r682"                           || fail "Unable to remove application workspace"
      mkdir -p "x11_r682"                           || fail "Unable to create application workspace"
      cd "x11_r682/"                                || fail "Unable to change into the application workspace"

      download_tarball "${x11_r682_TARBALL}"        || fail "Unable to download application tarball"
      tar xzvf "${x11_r682_TARBALL}"                || fail "Unable to unpack application tarball"
      cd "xc/"                                      || fail "Unable to change into application source directory"


      sed -i".bak" '41d' "extras/drm/shared/drm.h"  || fail "Unable to remove '#include <linux/config.h>' while patching drm.h"
      sed -i".bak" 's/programs//' "Imakefile"       || fail "Unable to remove programs from SUBDIRS"

      EXTRA_DEFINES="-I${ROSE_SH_DEPS_PREFIX}/include -I${ROSE_SH_DEPS_PREFIX}/workspace/x11_r682/xc/lib -I${ROSE_SH_DEPS_PREFIX}/workspace/x11_r682/xc/programs/Xserver/hw/xfree86/os-support -I${ROSE_SH_DEPS_PREFIX}/workspace/x11_r682/xc/programs/Xserver/hw/xfree86/common -I${ROSE_SH_DEPS_PREFIX}/workspace/x11_r682/xc/programs/Xserver/hw/xfree86"

      # TOO1 (3/15/2017): XDPSshare.c requires DPS/dpsops.h
      ln -s "${ROSE_SH_DEPS_PREFIX}/workspace/x11_r682/xc/lib/dps" "${ROSE_SH_DEPS_PREFIX}/workspace/x11_r682/xc/lib/DPS" || fail "Unable to symlink dps as DPS"

      LDFLAGS="$LDFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS" \
      EXTRA_DEFINES="${EXTRA_DEFINES}" \
          make World -j${parallelism} --keep-going || true

      # lib/GL/mesa/drivers/dri/common/xmlconfig.o requires expat.h
      make -C lib/GL/mesa/drivers/dri/common \
        -j${parallelism} --keep-going \
        EXTRA_INCLUDES="-I${ROSE_SH_DEPS_PREFIX}/include -I${ROSE_SH_DEPS_PREFIX}/workspace/x11_r682/xc/lib" || fail "An error occurred during compilation of lib/GL/mesa/drivers/dri/common"


# TOO1 (2/24/2014):
      # EXTRA_DEFINES: lib/X11 (KeyBind.o) requires expat.h
      # INSTALLED_LIBS: lib/Xft1 requires -lexpat

      # lib/font: Disable fontconfig and freetype
      # FONTCONFIGBUILDDIR: Skip lib/fontconfig since it has compilation errors; use our own fontconfig dependency installation
      # FREETYPEDIRS: Skip lib/font/FreeType; use our own freetype dependency installation
              #FREETYPEDIRS="" \
              #FREETYPESHAREDOBJS="" \
              #FREETYPESTATICOBJS="" \
      # FREETYPE2INCDIR: Trick build system to use our installed Freetype 2.1.0
#

      LDFLAGS="$LDFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CFLAGS="$CFLAGS" \
      EXTRA_DEFINES="${EXTRA_DEFINES}" \
      INSTALLED_LIBS="-L${ROSE_SH_DEPS_PREFIX}/lib" \
          make -j${parallelism} --keep-going \
              FONTCONFIGBUILDDIR="" \
              FREETYPE2INCDIR="${FREETYPE21_PREFIX}/include" \
              || fail "An error occurred during application compilation"

      make DESTDIR="${ROSE_SH_DEPS_PREFIX}" -j --keep-going
  else
      info "[SKIP] x11_r682 is already installed"
  fi
  #-----------------------------------------------------------------------------
  set +x
  #-----------------------------------------------------------------------------

  #-----------------------------------------------------------------------------
  rosesh__install_dep_teardown || exit 1
  #-----------------------------------------------------------------------------
}
