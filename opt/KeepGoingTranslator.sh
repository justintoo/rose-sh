#!/bin/bash

: ${KG__STRIP_PATH:="${application_abs_srcdir}/"}
: ${KG__EXPECTED_FAILURES_FILE:="${application_abs_srcdir}/rose-expected_failures.txt"}
: ${KG__EXPECTED_PASSES_FILE:="${application_abs_srcdir}/rose-expected_passes.txt"}
: ${KG__REPORT_FAIL:="${application_abs_srcdir}/rose-failures.txt"}
: ${KG__REPORT_PASS:="${application_abs_srcdir}/rose-passes.txt"}
: ${KG__ROSE_FLAGS:=}
#: ${KG__ROSE_FLAGS:=--verbose}

if test -n "${KG__STRIP_PATH}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --strip-path-prefix=${KG__STRIP_PATH}"
fi
#if test -n "${KG__EXPECTED_FAILURES_FILE}"; then
#  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --expected-failures=${KG__EXPECTED_FAILURES_FILE}"
#fi
#if test -n "${KG__EXPECTED_PASSES_FILE}"; then
#  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --expected-passes=${KG__EXPECTED_PASSES_FILE}"
#fi
if test -n "${KG__REPORT_FAIL}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --report-fail=${KG__REPORT_FAIL}"
fi
if test -n "${KG__REPORT_PASS}"; then
  KG__ROSE_FLAGS="${KG__ROSE_FLAGS} --report-pass=${KG__REPORT_PASS}"
fi

set -x
KeepGoingTranslator $* ${KG__ROSE_FLAGS} || exit 1
