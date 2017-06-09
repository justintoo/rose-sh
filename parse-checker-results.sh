#!/bin/bash

source ~/rose/setup.sh

: ${RULE_SELECTION:=~/compass/for-mysql/RULE_SELECTION}

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

checker_pattern="$(cat "${RULE_SELECTION}" | xargs | sed 's/[+:-]//g' | sed 's/ /:\\|/g')"

cat workspace/mysql-preprocessed/output.txt-20170604-141524-86310 | grep "${checker_pattern}" | sed 's/.*\[Phase 1\] \(.*\)/\1/'

