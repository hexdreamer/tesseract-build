#!/bin/zsh -f

_exec() {
  local _status

  if ! [ -d "${LOGS}" ]; then
    mkdir -p "${LOGS}"
  fi

  $@

  _status=$?
  if [ $_status -ne 0 ]; then
    echo 'ERROR running' $@ >&2
    return $_status
  fi

  echo $@ >>$MASTER_CMDS
  return 0
}

_exec_and_log() {
  # Try and execute a named step in the build process, and
  # log its stdout and stderr.
  #
  # pkgname :: the name of the pkg being configured/installed e.g., autoconf, leptonica
  # step :: intended to be a numbered step in the process of pkgname, e.g., 1_download, 2_configure
  # ${@:3} :: interpreted as "the command", (all arguments that follow pkgname and step)
  # Returns non-zero code for any error during execution.
  local pkgname=$1
  local step=$2
  local log_out="${LOGS}/${pkgname}/${step}.out"
  local log_err="${LOGS}/${pkgname}/${step}.err"
  local _status

  if ! [ -d ${LOGS}/${pkgname} ]; then
    mkdir -p ${LOGS}/${pkgname}
  fi

  ${@:3} >$log_out 2>$log_err

  _status=$?
  if [ $_status -ne 0 ]; then
    echo 'ERROR running' ${@:3} >&2
    echo "ERROR see $log_err for more details" >&2
    return "$_status"
  fi

  echo ${@:3} >>$MASTER_CMDS
  return 0
}

alias xc=_exec
alias xl=_exec_and_log

download() {
  local name=$1
  local url=$2
  local targz=$3

  if [ -e $DOWNLOADS/$targz ]; then
    # Substring replacement,
    #  '/Users/name/dev/project_root/SomePath/WeCareAbout'
    #  -->
    #                   '$PROJECTDIR/SomePath/WeCareAbout'
    # shellcheck disable=SC2016
    local _downloads=${DOWNLOADS/$PROJECTDIR/'$PROJECTDIR'}
    echo "Skipped download, found $_downloads/$targz"
    return 0
  fi

  print -n 'Downloading...'
  xc mkdir -p $DOWNLOADS || exit 1
  xl $name '0_curl' curl -L -f $url --output $DOWNLOADS/$targz || exit 1
  print ' done.'
}

extract() {
  local name=$1
  local targz=$2

  if [[ -n $3 ]]; then
    local dirname=$3
  else
    local dirname=$name
  fi

  if [ -d $SOURCES/$dirname ]; then
    # shellcheck disable=SC2016
    local _sources=${SOURCES/$PROJECTDIR/'$PROJECTDIR'}
    echo "Skipped extract of TGZ, found $_sources/$dirname"
    return 0
  fi

  print -n 'Extracting...'
  xc mkdir -p $SOURCES || exit 1
  xl $name '1_untar' tar -zxf $DOWNLOADS/$targz --directory $SOURCES || exit 1
  print ' done.'
}
