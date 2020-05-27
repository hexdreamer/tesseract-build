#! /bin/zsh -f

readonly _PROGNAME=$0:A
readonly _SCRIPTSDIR=${_PROGNAME%/run_tests.sh}

${_SCRIPTSDIR}/test_configs.sh
${_SCRIPTSDIR}/test_exec.sh
${_SCRIPTSDIR}/test_exec_and_log.sh