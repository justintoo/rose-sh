#!/bin/bash

set -x
spack install --no-checksum $* || exit 1
