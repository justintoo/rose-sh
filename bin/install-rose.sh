#!/bin/bash

: ${ROSE_VERSION:=master}

if [ "$#" -lt 1 ]; then
    echo "[FATAL] usage: $(basename "$0") <ROSE_VERSION> [args]"
    exit 1
elif [ "$#" -ge 1 ]; then
    ROSE_VERSION="$1"
    shift
fi

set -x
spack install --no-checksum rose@${ROSE_VERSION} $* || exit 1
