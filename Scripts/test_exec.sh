#! /bin/zsh

readonly _PROGNAME=$0:A
readonly _SCRIPTSDIR=${_PROGNAME%/test_exec.sh}
readonly TMP_DIR=${_SCRIPTSDIR}/tmp

# shellcheck disable=SC1091
source ${_SCRIPTSDIR}/build.sh unittest

LOG_DIR="${TMP_DIR}/Logs"
MASTER_CMDS="${LOG_DIR}/master_commands.sh"

createTmpDir() {
  if ! [ -d "$TMP_DIR" ]; then
    mkdir "$TMP_DIR"
  fi
}

destroyTmpDir() {
  if [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}

setUp() {
  createTmpDir
}

tearDown() {
  destroyTmpDir
}

testMasterCommand() {
    cat << EOF > _commands.sh
mkdir foo
cd foo
touch bar
mkdir baz
cd baz
touch zab
cd ..
cd ..
tar -cf foo.tar foo
rm -rf foo
EOF

    _exec mkdir foo
    _exec cd foo
    _exec touch bar
    _exec mkdir baz
    _exec cd baz
    _exec touch zab
    _exec cd ..
    _exec cd ..
    _exec tar -cf foo.tar foo
    _exec rm -rf foo

    assertTrue "Commands are not equal" "cmp $MASTER_CMDS _commands.sh"

    mv foo.tar foo.tar.original
    zsh $MASTER_CMDS

    assertEquals "$(tar -tf foo.tar.original)" "$(tar -tf foo.tar)"
    
    rm _commands.sh foo.tar foo.tar.original
    fail
}


setopt shwordsplit
export SHUNIT_PARENT=$0

# shellcheck disable=SC1091
source ${_SCRIPTSDIR}/shunit2/shunit2
