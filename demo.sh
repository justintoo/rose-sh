#!/bin/bash

source ~/rose/setup.sh

: ${RULE_SELECTION:=~/compass/RULE_SELECTION}
: ${RESULTS_FILE:="$(pwd)/results.txt"}

# == Sample Output
#
# [INFO] [20170605-19:58:27] [truecrypt] [Phase 1] NullDeref: /home/ec2-user/opt/boost/~/rose/master/edg-4.12-c++11/installation/include/edg/g++_HEADERS/hdrs1/bits/basic_string.tcc:422.32-39: could be NULL: stack is:
# [INFO] [20170605-19:58:27] [truecrypt] [Phase 1] FunctionDocumentation: /home/ec2-user/opt/boost/~/rose/master/edg-4.12-c++11/installation/include/edg/g++_HEADERS/hdrs1/bits/locale_facets.tcc:1238.3-1273.5: function is not documented: name =  ::std::__add_grouping
# [INFO] [20170605-19:58:27] [truecrypt] [Phase 1] FunctionDocumentation: /home/ec2-user/opt/boost/~/rose/master/edg-4.12-c++11/installation/include/edg/g++_HEADERS/hdrs1/bits/basic_ios.tcc:41.33-49.5: function is not documented: name =  ::std::basic_ios::clear

# == Sample RULE_SELECTION
#
# +:NonmemberFunctionInterfaceNamespace
# +:NullDeref
# +:OmpPrivateLock

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

  wxwidgets_pattern="wget.*wxWidgets-2.8.12.tar.gz"
  if test "x$(echo "${line}" | grep "${wxwidgets_pattern}")" != "x"; then
    echo "[  5%] Installing wxWidgets"
  fi

  make_pattern="make \\-\\-keep\\-going"
  if test "x$(echo "${line}" | grep "${make_pattern}")" != "x"; then
    echo "[ 15%] Analyzing TrueCrypt"
  fi

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
done < <(cat workspace/truecrypt-preprocessed/checker-results.txt)
#done < <(cat workspace/truecrypt-preprocessed/output.txt-20170503-192321-96396)
#done < <(ROSE_CC=compassMain ROSE_CXX=compassMain ./rose.sh --clean --keep-going truecrypt 2>&1)

	echo "[100%] Successfully analyzed TrueCrypt"

