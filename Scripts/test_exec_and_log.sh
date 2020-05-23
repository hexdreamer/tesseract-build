#! /bin/zsh

# Tried doing it the right way, `shellcheck source=build.sh`, but still got error
# shellcheck disable=SC1091
# Include unittest positional arg so build.sh doesn't try to build anything
source build.sh unittest

readonly TMP_DIR=./tmp
readonly ERR="${TMP_DIR}/err"
readonly OUT="${TMP_DIR}/out"

LOG_DIR="${TMP_DIR}/Logs"

createTmpDir() {
  if ! [ -d "$TMP_DIR" ]; then
    mkdir "$TMP_DIR"
  fi
}

destroyTmpDir() {
  if [[ -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}

destroyErrOut() {
  if [[ -f "$ERR" ]]; then
    rm "$ERR"
  fi

  if [[ -f "$OUT" ]]; then
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
  assertNull "$(cat <$ERR)"
  assertNull "$(cat <$OUT)"

  assertTrue "Expected to find $logdir" "[ -d $logdir ]"
}

testExecAndLogFailure() {
  exec_and_log "pkg-foo" "2_list_bar" ls "${TMP_DIR}/bar" >"$OUT" 2>"$ERR"
  _status=$?

  assertEquals "checking return code for bad command;" 1 "$_status"
  assertContains "$(cat <$ERR)" "ERROR"
  assertNull "$(cat <$OUT)"
}

testExecAndLogSuccess() {
  logdir="${LOG_DIR}/pkg-foo"

  exec_and_log "pkg-foo" "1_touch_bar" touch "${TMP_DIR}/bar" >"$OUT" 2>"$ERR"
  _status=$?

  assertEquals "checking return code for good command;" 0 "$_status"
  assertNull "$(cat <$OUT)"
  assertNull "$(cat <$ERR)"

  exec_and_log "pkg-foo" "2_list_bar" ls "${TMP_DIR}/bar" >"$OUT" 2>"$ERR"
  _status=$?
  assertContains "$(cat <${logdir}/2_list_bar.out)" "${TMP_DIR}/bar"
  assertNull "$(cat <$ERR)"
}

setopt shwordsplit
export SHUNIT_PARENT=$0

# shellcheck disable=SC1091
source shunit2/shunit2
