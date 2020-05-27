#! /bin/zsh


# shellcheck disable=SC1091
# Include unittest positional arg so build.sh doesn't try to build anything
source build.sh unittest

readonly _PROGNAME=$0:A
readonly _SCRIPTSDIR=${_PROGNAME%/test_exec.sh}
readonly TMP_DIR=${_SCRIPTSDIR}/tmp
LOG_DIR="${TMP_DIR}/Logs"

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

    assertTrue "Commands are not equal" "cmp ${LOG_DIR}/commands.sh _commands.sh"

    mv foo.tar foo.tar.original
    zsh ${LOG_DIR}/commands.sh

    assertEquals "$(tar -tf foo.tar.original)" "$(tar -tf foo.tar)"
    
    rm _commands.sh foo.tar foo.tar.original
}


setopt shwordsplit
export SHUNIT_PARENT=$0

# shellcheck disable=SC1091
source shunit2/shunit2
