#!/bin/bash

: ${PATCHESDIR:="rose_patches"}
: ${ROSE_SH_HOME:="$(dirname "0")/.."}
: ${application:="$1"}

if [ -z "${application}" ]; then
  echo "[FATAL] \$application is undefined"
  exit 1
fi

pushd "${ROSE_SH_HOME}/workspace/${application}/phase_1/${application}-src" || exit 1

    rm -rf "./${PATCHESDIR}" || exit 1
    rm -rf "./${PATCHESDIR}.tgz*" || exit 1

    echo "[INFO] Collecting ROSE patches"

    for patch in $(find . -iname "*\.rpatch"); do
      filename="$(basename "${patch}")"
      original_filename="${filename%.rpatch}"
      directory="$(dirname "${patch}")"
    
      #echo "[DEBUG] filename=${filename}, directory=${directory}"
    
      mkdir -p "${PATCHESDIR}/${directory}" || exit 1
      cp "${directory}/${filename}" "${PATCHESDIR}/${directory}" || exit 1
      cp "${directory}/${original_filename}" "${PATCHESDIR}/${directory}" || exit 1
      cp "../rose-workspace/${directory}/rose_${original_filename}" "${PATCHESDIR}/${directory}" || exit 1
    done
    
    echo "[INFO] Creating tarball of ROSE patches (original files, rose_* files, and *.rpatch files)"
    tar czvf "${PATCHESDIR}.tgz" "${PATCHESDIR}" || exit 1

popd

echo "Success!"

