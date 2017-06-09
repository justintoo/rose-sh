#!/bin/bash

source ~/rose/setup.sh

: ${RULE_SELECTION:=~/compass/for-mysql/RULE_SELECTION}
: ${PREPROCESSED_FILE:="$(pwd)/workspace/mysql-preprocessed/checker-results.txt"}
: ${RESULTS_FILE:="$(pwd)/results.txt"}

SECONDS=0

declare -A DEPS
declare -A CHECKER_COUNT

function print_runtime() {
  local duration=$SECONDS
  local minutes="$(($duration / 60))" seconds="$(($duration % 60))"
  echo -en "\r[$(printf "%02d:%02d" "${minutes}" "${seconds}")] "
}

while IFS= read -r line; do
  deps_pattern="\[install_dep=.*Installing application"
  if test "$(echo "${line}" | grep "${deps_pattern}")"; then
    dep="$(echo "${line}" | sed 's/.*\[install_dep=\(.*\)\] \[INFO.*/\1/')"
    if test "x${DEPS[$dep]}" = "x"; then
      echo "[  1%] Installing ${dep}"
    else
      DEPS[$dep]="already-seen"
    fi
  fi

  boost_pattern="wget.*mysql-boost-5.7.17.tar.gz"
  if test "x$(echo "${line}" | grep "${boost_pattern}")" != "x"; then
    echo "[  5%] Installing Boost"
  fi

  make_pattern="make.*VERBOSE=1"
  if test "x$(echo "${line}" | grep "${make_pattern}")" != "x"; then
    echo "[ 15%] Analyzing MySQL"
  fi

  #checker_pattern="$(cat "${RULE_SELECTION}" | xargs | sed 's/[+:-]//g' | sed 's/ /\\:|/g')"
  #if test "x$(echo "${line}" | grep "${checker_pattern}")" != "x"; then
  #  echo "${line}" | sed 's/.*\[Phase 1\] \(.*\)/\1/'
  #fi

  checker_pattern="$(cat "${RULE_SELECTION}" | xargs | sed 's/[+:-]//g' | sed 's/ /:\\|/g')"
  if test "x$(echo "${line}" | grep "${checker_pattern}")" != "x"; then
    # for live results
    #echo "${line}" | sed 's/.*\[Phase 1\] \(.*\)/\1/'

    checker="$(echo $line | awk 'BEGIN{FS=":"} {print $1}' | tr -d '\n')"
    let '++CHECKER_COUNT[$checker]'
    #echo "(${CHECKER_COUNT[$checker]}) $checker"
  fi

    HEADER="# Checker # Checker"

    TOTAL=0
    OUTPUT=""
    for checker in $(cat "${RULE_SELECTION}" | xargs | sed 's/[+:-]//g'); do
      OUTPUT="$OUTPUT (${CHECKER_COUNT[$checker]-0}) $checker"
      let TOTAL=TOTAL+CHECKER_COUNT[$checker]
    done
    printf "%-6s %-45s %-6s %-45s\n" $HEADER $OUTPUT > results.txt
    clear

    rows=$(($(tput lines) - 8))
    displayed_checkers=$((${rows} * 2 - 1))
    head --lines ${rows} "${RESULTS_FILE}"
    printf "%0.s=" $(seq 4 $(tput cols))
    echo
    echo "($TOTAL) total checker detections, displaying ${displayed_checkers}/$(cat $RULE_SELECTION | wc -l) checkers from ${RESULTS_FILE}."
    printf "%0.s=" $(seq 4 $(tput cols))
    echo

  print_runtime
done < <(cat "${PREPROCESSED_FILE}")
#done < <(cat workspace/mysql-preprocessed/output.txt-20170604-141524-86310)
#done < <(ROSE_CC=compassMain ROSE_CXX=compassMain ./rose.sh --clean --keep-going truecrypt 2>&1)

echo "[100%] Successfully analyzed MySQL"

