#!/bin/bash

set -x
spack install --no-checksum rosesh.rose@$* || exit 1
