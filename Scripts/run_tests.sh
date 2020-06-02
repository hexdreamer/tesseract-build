#!/bin/zsh -f

readonly _PROGNAME=$0:A
readonly _SCRIPTSDIR=${_PROGNAME%/run_tests.sh}

tests=(
    ${_SCRIPTSDIR}/test_configs.sh
    ${_SCRIPTSDIR}/test_exec.sh
    ${_SCRIPTSDIR}/test_exec_and_log.sh
)

msg=()
for i in $tests
do
    _msg=$($i)
    _status=$?
    if [ $_status -ne 0 ]; then
        msg=($msg $_msg)
    fi
done

if [[ -n $msg ]]; then
    printf '%s\n' $msg
    exit 1
fi