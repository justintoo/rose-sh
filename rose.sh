#!/usr/bin/env bash
set -e

export ROSE_SH_HOME="$(cd "$(dirname "$0")" && pwd)"
export PATH="${ROSE_SH_HOME}/opt:${PATH}"
export PYTHONPATH="${ROSE_SH_HOME}/opt/filelock-0.2.0/installation/lib/python2.7/site-packages:${PYTHONPATH}"

source /nfs/casc/overture/ROSE/opt/rhel6/x86_64/sqlite/308002/gcc/4.4.5/setup.sh || true

#-------------------------------------------------------------------------------
# Set defaults
#-------------------------------------------------------------------------------
: ${ROSE_CC:="$(which identityTranslator)"}
: ${ROSE_CXX:="$(which identityTranslator)"}
: ${CC:="gcc"}
: ${CXX:="g++"}
: ${JAVAC:="javac"}
: ${workspace:="$(pwd)/workspace"}
: ${parallelism:=$(cat /proc/cpuinfo | grep processor | wc -l)}
: ${VERBOSE:=1}
: ${TMPDIR:=/tmp}

#-------------------------------------------------------------------------------
export APPLICATIONS_DIR="${ROSE_SH_HOME}/applications"
export APPLICATIONS_LIST="$(ls ${APPLICATIONS_DIR}/ | xargs -I{} basename {} | sort)"
#-------------------------------------------------------------------------------
: ${ROSE_SH_REUSE_WORKSPACE:=true}
: ${ROSE_SH_ENABLE_CONFIGURE:=true}
: ${ROSE_SH_ENABLE_PHASE_2:=false}
: ${ROSE_SH_CLOBBER_MODE:=}
#-------------------------------------------------------------------------------
: ${REPOSITORY_MIRROR_URLS:=
  https://bitbucket.org/rose-compiler
  rose-dev@rosecompiler1.llnl.gov:rose/c
  rose-dev@rosecompiler1.llnl.gov:rose/cxx
  }
: ${TARBALL_MIRROR_URLS:=
  http://hudson-rose-30.llnl.gov:8080/userContent/tarballs/dependencies
  https://bitbucket.org/rose-compiler/rose-sh/downloads
  https://rosecompiler1.llnl.gov:8443/jenkins-edg4x/userContent/tarballs/dependencies
  http://portal.nersc.gov/project/dtec/tarballs/dependencies
  }
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
rosesh__install_dep_setup()
#-------------------------------------------------------------------------------
{
  mkdir -p "${ROSE_SH_DEPS_PREFIX}/workspace" || fail "Could not create the installation workspace directory"
  pushd "${ROSE_SH_DEPS_PREFIX}/workspace"    || fail "Could not cd into the installation workspace directory"
}

#-------------------------------------------------------------------------------
rosesh__install_dep_teardown()
#-------------------------------------------------------------------------------
{
  popd || exit 1
}

#-------------------------------------------------------------------------------
install_deps() # $*=dependencies
#-------------------------------------------------------------------------------
{
  declare -r DEPENDENCIES="$*"

  info "[Dependencies] External dependencies: '${DEPENDENCIES}'"

  if [ -z "${DEPENDENCIES}" ]; then
    return 0
  else
    for dep in ${DEPENDENCIES}; do
      (

            install_${dep} || exit 1

      ) 2>&1 | while read; do echo "[install_dep=${dep}] ${REPLY}"; done
      [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed installation of dependency '${dep}'" || true
    done
  fi
}

#-------------------------------------------------------------------------------
# Utilities
#-------------------------------------------------------------------------------
info() { printf "[INFO] $*\n" ; return 0 ; }
fail() { printf "\n[FATAL] $*\n" 1>&2 ; exit 1 ; }

clone_repository()
{
  local repository_name="$1" local_clone_name="$2"
  : ${local_clone_name:="${repository_name}-src"}

  if [ "x${ROSE_SH_REUSE_WORKSPACE}" = "xtrue" ]; then
      if [ -d "${local_clone_name}" ]; then
          info "[SKIP] Reusing application workspace: '${local_clone_name}'"
          return 0
      else
          info "Cannot reuse non-existant application workspace: '${local_clone_name}'"
      fi
  fi

  [ -z "${repository_name}" ] && fail "Usage: clone_repository <repository_name>"

  for mirror_url in ${REPOSITORY_MIRROR_URLS}; do
    local repository_url="${mirror_url}/${repository_name}.git"

    info "Attempting to git-clone: '${repository_url}'"

    git clone --progress "${repository_url}" "${local_clone_name}" >&1
    if test $? -eq 0; then
        return 0
    else
        info "Could not clone '${repository_name}' from mirror '${mirror_url}'"
        continue
    fi
  done

  fail "Unable to clone '${repository_name}'"
}

download_tarball()
{
  local tarball="$1"
  [ -z "${tarball}" ] && fail "Usage: download_tarball <tarball>"

  for mirror_url in ${TARBALL_MIRROR_URLS}; do
    local tarball_url="${mirror_url}/${tarball}"

    info "Attempting tarball download: '${tarball_url}'"

    wget --no-check-certificate "${tarball_url}"
    if test $? -eq 0; then
        return 0
    else
        info "Could not download '${tarball}' from mirror '${mirror_url}'"
        continue
    fi
  done

  fail "Unable to download '${tarball}'"
}

#-------------------------------------------------------------------------------
usage()
#-------------------------------------------------------------------------------
{
  cat <<-EOF
--------------------------------------------------------------------------------
Help Information for ROSE-SH
--------------------------------------------------------------------------------

  Usage:

      $ [Environment Variables] ./rose.sh <application> [--help]

  Description
      Compiles <application> after installing any dependencies.

      A new directory "./workspace/<application>" will be created
      to be used as the application's workspace.

      Dependencies are installed to a new directory:
      "./dependencies/installation"

  Example:
      $ ROSE_CC="\$(which identityTranslator)" ./rose.sh apache_cassandra

  Applications:
    $(echo ${APPLICATIONS_LIST} | xargs)

  Options
    --help            Display this help information and exit.
    --clean           ROSE_SH_REUSE_WORKSPACE=false.
    --serial          Utilize only one CPU core. (Default: Use all CPU cores.)

                      If you want to specify your own number of CPU cores, set
                      the environment variable 'parallelism'. For example:

                          $ parallelism=12 ./rose.sh ffmpeg
    --keep-going      Use the opt/KeepGoingTranslator.sh ROSE compiler.

  Environment Variables:
    ROSE_CC       The ROSE compiler used during Stage 1 of testing; must be
                  absolute path to compiler. (Use for C/C++/Java.)

    CC            The C compiler used during Stage 2 of testing (default: gcc)
    JAVAC         The Java compiler used during Stage 2 of testing (default: javac)

    parallelism   The number of CPU cores to pass to make -j#.

    ROSE_SH_DEPS_PREFIX         (Re-)Use this dependencies prefix directory.
    ROSE_SH_REUSE_WORKSPACE     Reuse application workspace if it exists (default: true).
    ROSE_SH_ENABLE_PHASE_2      Perform application tests with the ROSE translated
                                source code (default: false).

--------------------------------------------------------------------------------
EOF
}

#-------------------------------------------------------------------------------
phase_1()
#-------------------------------------------------------------------------------
{
  info "Performing Phase 1"

  export application_abs_srcdir="${application_workspace}/phase_1/${application}-src"

  mkdir -p "${application_workspace}/phase_1" || fail "phase_1::create_workspace failed"
  pushd "${application_workspace}/phase_1"    || fail "phase_1::cd_into_workspace failed"
      "install_deps_${application}"           || fail "phase_1::install_deps failed with status='$?'"

      "download_${application}"               || fail "phase_1::download failed with status='$?'"
      # TOO1 (3/12/2014): For KeepGoingTranslator
      export APPLICATION_SRCDIR="$(pwd)"

if [ "x$ROSE_SH_ENABLE_CONFIGURE" = "xtrue" ]; then
      "patch_${application}"                  || fail "phase_1::patch failed with status='$?'"
      "configure_${application}__rose"        || fail "phase_1::configure_with_rose failed with status='$?'"
fi
      "compile_${application}"                || fail "phase_1::compile failed with status='$?'"
  popd
}

#-------------------------------------------------------------------------------
phase_2()
#-------------------------------------------------------------------------------
{
  info "Performing Phase 2"

  mkdir -p "${application_workspace}/phase_2" || fail "phase_2::create_workspace failed"
  pushd "${application_workspace}/phase_2"    || fail "phase_2::cd_into_workspace failed"
      "install_deps_${application}"           || fail "phase_2::install_deps failed with status='$?'"

      "download_${application}"               || fail "phase_2::download failed with status='$?'"
      # TOO1 (3/12/2014): For KeepGoingTranslator
      export APPLICATION_SRCDIR="$(pwd)"

      "patch_${application}"                  || fail "phase_2::patch failed with status='$?'"

      set -x
          LIST_OF_FILES_TO_SKIP="${application_workspace}/phase_2/${application}-src/rose-skip_files.txt"
          if [ -f "${LIST_OF_FILES_TO_SKIP}" ]; then
              info "Will skip staging of $(cat "${LIST_OF_FILES_TO_SKIP}") files:"
              cat "${LIST_OF_FILES_TO_SKIP}"
          fi

          # Replace application source code files with ROSE translated source code files
          "${ROSE_SH_HOME}/opt/stage_rose.sh"                                               \
              -f                                                                            \
              -s "${application_workspace}/phase_2/${application}-src/rose-skip_files.txt"  \
              "${application_workspace}/phase_1/${application}-src"                         \
              "${application_workspace}/phase_2/${application}-src"                         \
                                                  || fail "phase2::stage_rose.sh failed"

          # Save the diff with the updated ROSE files
          pushd "${application_workspace}/phase_2/${application}-src" || fail "phase_2::cd_into_source_dir failed"
              git diff --patch > "add_rose_translated_sources.patch"  || fail "phase_2::generate_diff_patch failed"
              git add "add_rose_translated_sources.patch"             || fail "phase_2::git_add_diff_patch failed"
              git commit -a -m "Add ROSE translated sources"          || fail "phase_2::git_commit_rose_diff failed"
          popd
          tar czvf \
              "${application_workspace}/phase_2/${application}-src-rose.tgz" \
              "${application_workspace}/phase_2/${application}-src"   || fail "phase_2::create_application_tarball_containing_rose_sources failed"
      set +x

      "configure_${application}__gcc"   || fail "phase_2::configure_with_gcc failed with status='$?'"
      "compile_${application}"          || fail "phase_2::compile failed with status='$?'"
  popd
}

#-------------------------------------------------------------------------------
main()
#-------------------------------------------------------------------------------
{
    info "Performing main()"

    #-------------------------------------------------------------------------------
    # Source application build function
    #-------------------------------------------------------------------------------
    if [ -z "${APPLICATION_SCRIPT}" -o ! -f "${APPLICATION_SCRIPT}" ]; then
        fail "Application script does not exist: '${APPLICATION_SCRIPT}'"
    else
        info "Sourcing application script '${APPLICATION_SCRIPT}'"
        source "${APPLICATION_SCRIPT}" || exit 1
    fi

      (

          phase_1 || exit 1

      ) 2>&1 | while read; do echo "[Phase 1] ${REPLY}"; done
      [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Phase 1 of '${application}'" || true

if [ "x$ROSE_SH_ENABLE_PHASE_2" = "xtrue" ]; then
      (

          phase_2 || exit 1

      ) 2>&1 | while read; do echo "[Phase 2] ${REPLY}"; done
      [ ${PIPESTATUS[0]} -ne 0 ] && fail "Failed during Phase 2 of '${application}'" || true
fi

    popd
}

#-------------------------------------------------------------------------------
# CLI Options
#-------------------------------------------------------------------------------
if [ "$#" -eq 0 ]; then
  usage
  exit 1
fi

for arg in $*; do
  case $arg in
    --clean)        export ROSE_SH_REUSE_WORKSPACE=false; shift;;
    --silent)       export VERBOSE=0; V=0; shift;;
    --verbose)      export VERBOSE=1; V=1; shift;;
    help)           usage; shift; exit 0;;
    --help)         usage; shift; exit 0;;
    -h)             usage; shift; exit 0;;
    --serial)       export parallelism="1"; shift;;
    --keep-going)   export ROSE_CC="$(which KeepGoingTranslator.py)"; shift;;
    --disable-configure-step)   export ROSE_SH_ENABLE_CONFIGURE="false"; shift;;
    --clobber)      export ROSE_SH_CLOBBER_MODE="-rose:unparser:clobber_input_file"; shift;;
    --install-dependency)
        export ROSE_SH__ACTION__INSTALL_DEPENDENCY="true"
        shift
      ;;
    *)          export application="$arg"; shift;;
  esac
done

#-------------------------------------------------------------------------------
# Dependencies
#-------------------------------------------------------------------------------
export DEPENDENCIES_DIR__DEFAULT="${ROSE_SH_HOME}/dependencies"
export DEPENDENCIES_LIST__DEFAULT="$(find ${DEPENDENCIES_DIR__DEFAULT} -maxdepth 2 -type f -iname "*\.sh")"

export DEPENDENCIES_DIR__CUSTOM="${ROSE_SH_HOME}/applications/${application}/dependencies"
if [ -d "${DEPENDENCIES_DIR__CUSTOM}" ]; then
    export DEPENDENCIES_LIST__CUSTOM="$(ls ${DEPENDENCIES_DIR__CUSTOM}/*.sh)"
fi

: ${ROSE_SH_DEPS_PREFIX:="${DEPENDENCIES_DIR__DEFAULT}/installation/${application}"}
export ROSE_SH_DEPS_LIBDIR="${ROSE_SH_DEPS_PREFIX}/lib"

: ${LDFLAGS:=-L"${ROSE_SH_DEPS_PREFIX}/lib" -L"${ROSE_SH_DEPS_PREFIX}/lib64" -Wl,-z,relro -Wl,-R"${ROSE_SH_DEPS_PREFIX}/lib" -Wl,-R"${ROSE_SH_DEPS_PREFIX}"/lib "-L${LIBTOOL_HOME}/lib"}
: ${CFLAGS:=-I"${ROSE_SH_DEPS_PREFIX}/include" "-I${LIBTOOL_HOME}/include"}
: ${CPPFLAGS:=-I"${ROSE_SH_DEPS_PREFIX}/include" "-I${LIBTOOL_HOME}/include"}
: ${ACLOCAL_PATH:="${ROSE_SH_DEPS_PREFIX}/share/aclocal:/usr/share/aclocal"}
export PKG_CONFIG_PATH="${ROSE_SH_DEPS_PREFIX}/lib:${ROSE_SH_DEPS_PREFIX}/lib/pkgconfig:${ROSE_SH_DEPS_PREFIX}/lib64:${ROSE_SH_DEPS_PREFIX}/lib64/pkgconfig:${ROSE_SH_DEPS_PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH}"
export PATH="${ROSE_SH_DEPS_PREFIX}/bin:${ROSE_SH_DEPS_PREFIX}/sbin:${PATH}"
export LD_LIBRARY_PATH="${ROSE_SH_DEPS_PREFIX}/lib:${ROSE_SH_DEPS_PREFIX}/lib64:${LD_LIBRARY_PATH}"

# TOO1 (1/30/2014) Required for proper use of ROSE_SH/dependencies/installation/bin/ant,
#                  even if we have ROSE_SH/dependencies/installation/bin in our PATH.
#                  This is just an annoying subtlety of Ant.
export ANT_HOME="${ROSE_SH_DEPS_PREFIX}"

# TOO1 (2/11/2014): Required for proper use of ROSE_SH/dependencies/installation/bin/mvn.
export M2_HOME="${ROSE_SH_DEPS_PREFIX}"

export APPLICATION_SCRIPT="${APPLICATIONS_DIR}/${application}/${application}.sh"
: ${application_workspace:="${workspace}/${application}"}
: ${application_log:="${application_workspace}/output.txt-$(date +%Y%m%d-%H%M%S)-$$"}

# Build in a separate workspace, so we don't pollute the user's current directory.
if [ "x${ROSE_SH_REUSE_WORKSPACE}" != "xtrue" ]; then
    rm -rf "${application_workspace}"   || fail "main::remove_workspace failed"
fi
mkdir -p "${application_workspace}" || fail "main::create_workspace failed"
pushd "${application_workspace}"    || fail "main::cd_into_workspace failed"

#-------------------------------------------------------------------------------
# Source default dependencies
#-------------------------------------------------------------------------------
for dependency in $DEPENDENCIES_LIST__DEFAULT; do
    #info "Sourcing default dependency script '${dependency}'"
    source "${dependency}" || exit 1
done

#-------------------------------------------------------------------------------
# Source custom dependencies (overrides defaults)
#-------------------------------------------------------------------------------
if [ -n "${DEPENDENCIES_LIST__CUSTOM}" ]; then
    for dependency in $DEPENDENCIES_LIST__CUSTOM; do
        #info "Sourcing custom dependency script '${dependency}'"
        source "${dependency}" || exit 1
    done
fi

if [ "x${ROSE_SH__ACTION__INSTALL_DEPENDENCY}" = "xtrue" ]; then
  install_deps "${application}" || fail "Could not install dependency '$1'"
  echo "Successfully installed dependency '$1'"
  exit 0
fi

#-------------------------------------------------------------------------------
# Entry point for program execution
#-------------------------------------------------------------------------------
(
    main || fail "Main program execution failed"

)  2>&1 | while read; do echo "[INFO] [$(date +%Y%m%d-%H:%M:%S)] [${application}] ${REPLY}"; done | tee "${application_log}"
if [ ${PIPESTATUS[0]} -ne 0 ]; then
  info ""
  info "-------------------------------------------------------------------------------"
  info "Failed during execution of '${application}' tests. See log output: '${application_log}'"
  info ""
  cat "${application_log}" | grep "FATAL" | sed 's/\[INFO\]/[BACKTRACE]/g'
  info ""
  fail "Terminated with failure."
  exit 1
fi

info "-------------------------------------------------------------------------------"
info "SUCCESS"
exit 0
