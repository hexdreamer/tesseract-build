#! /bin/zsh

readonly _PROGNAME=$0:A
readonly _SCRIPTSDIR=${_PROGNAME%/test_exec_and_log.sh}
readonly TMP_DIR=${_SCRIPTSDIR}/tmp

# shellcheck disable=SC1091
source ${_SCRIPTSDIR}/build.sh unittest

readonly ERR=${TMP_DIR}/err
readonly OUT=${TMP_DIR}/out

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

destroyErrOut() {
  if [ -f "$ERR" ]; then
    rm $ERR
  fi

  if [ -f "$OUT" ]; then
    rm "$OUT"
  fi
}

setUp() {
  createTmpDir
}

tearDown() {
  destroyTmpDir
}

testExecAndLogDirectories() {
  logdir="${LOG_DIR}/pkg-foo"
  assertFalse "Did not expect to find $logdir" "[ -d $logdir ]"

  exec_and_log "pkg-foo" "1_touch_bar" touch "${TMP_DIR}/bar" >"$OUT" 2>"$ERR"
  err=$(cat <"$ERR")
  assertNull "$err"
  out=$(cat <"$OUT")
  assertNull "$out"

  assertTrue "Expected to find $logdir" "[ -d \"$logdir\" ]"
}

testExecAndLogFailure() {
  exec_and_log "pkg-foo" "2_list_bar" ls "${TMP_DIR}/bar" >"$OUT" 2>"$ERR"
  _status=$?
  err=$(cat <"$ERR")
  out=$(cat <"$OUT")

  assertEquals "checking return code for bad command;" 1 "$_status"
  assertContains "$err" "ERROR"
  assertNull "$out"

  exec_err=$(cat "${logdir}/2_list_bar.err")
  assertContains "checking stderr of bad command;" "$exec_err" "${TMP_DIR}/bar: No such file or directory"
}

testExecAndLogSuccess() {
  logdir="${LOG_DIR}/pkg-foo"

  exec_and_log "pkg-foo" "1_touch_bar" touch "${TMP_DIR}/bar" >"$OUT" 2>"$ERR"

  _status=$?
  err=$(cat <"$ERR")
  out=$(cat <"$OUT")

  assertEquals "checking return code for good command;" 0 "$_status"
  assertNull "Err file for 1_touch_bar not empty" "$err"
  assertNull "Out file for 1_touch_bar not empty" "$out"

  exec_and_log "pkg-foo" "2_list_bar" ls "${TMP_DIR}/bar" >"$OUT" 2>"$ERR"

  _status=$?
  err=$(cat <"$ERR")
  out=$(cat <"$OUT")

  assertEquals "checking return code for good command;" 0 "$_status"
  assertNull "Err file for 2_list_bar not empty" "$err"
  assertNull "Out file for 2_list_bar not empty" "$out"
  
  exec_out=$(cat "${logdir}/2_list_bar.out")
  assertContains "$exec_out" "${TMP_DIR}/bar"
}

setopt shwordsplit
export SHUNIT_PARENT=$0

# shellcheck disable=SC1091
source ${_SCRIPTSDIR}/shunit2/shunit2
