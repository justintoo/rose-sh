#!/bin/bash

: ${APPLICATION_SRCDIR:="$(pwd)"}
: ${KG__STRIP_PATH:="${APPLICATION_SRCDIR}/"}
: ${KG__EXPECTED_FAILURES_FILE:="${APPLICATION_SRCDIR}/rose-expected_failures.txt"}
: ${KG__EXPECTED_PASSES_FILE:="${APPLICATION_SRCDIR}/rose-expected_passes.txt"}
: ${KG__REPORT_FAIL:="${APPLICATION_SRCDIR}/rose-failures.txt"}
: ${KG__REPORT_PASS:="${APPLICATION_SRCDIR}/rose-passes.txt"}
: ${KG__ROSE_FLAGS:=--verbose}

if test -n "${KG__STRIP_PATH}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --strip-path-prefix=${KG__STRIP_PATH}"
fi
if test -n "${KG__EXPECTED_FAILURES_FILE}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --expected-failures=${KG__EXPECTED_FAILURES_FILE}"
fi
if test -n "${KG__EXPECTED_PASSES_FILE}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --expected-passes=${KG__EXPECTED_PASSES_FILE}"
fi
if test -n "${KG__REPORT_FAIL}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --report-fail=${KG__REPORT_FAIL}"
fi
if test -n "${KG__REPORT_PASS}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --report-pass=${KG__REPORT_PASS}"
fi

set -x
KeepGoingTranslator $* ${KG__ROSE_FLAGS} || exit 1
