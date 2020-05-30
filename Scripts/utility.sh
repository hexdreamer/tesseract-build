#! /bin/zsh -f

check_installed() {
  # An idea for checking installations
  filepath=$( find /Users/zyoung/dev/tesseract-build/Root/bin \( -newer /Users/zyoung/dev/tesseract-build/Sources/automake-1.16/x86_64/Makefile -a -name 'automake' \) )
  version_str=$(/Users/zyoung/dev/tesseract-build/Root/bin/automake --version 2>&1)
  if {
      [[ $version_str == *'1.16'* ]] &&
          [[ $filepath == /Users/zyoung/dev/tesseract-build/Root/bin/automake ]]
  }; then
      echo "Properly installed."
  fi
}

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
 
  echo $@ >> $MASTER_CMDS
  return 0
}

exec_and_log() {
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
  
  echo ${@:3} >> $MASTER_CMDS
  return 0
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      unittest)
        return $ABORT_BUILD
        ;;
      -h)
        echo
        echo Download and build Tesseract OCR, and all tooling
        echo
        echo '  -d        set -x for debugging'
        echo '  -h        print this message'
        echo
        echo '  clean     remove all artifacts from Root, Downloads, and Sources'
        echo

        return $ABORT_BUILD
        ;;
      -d)
        DEBUG=true
        set -x
        ;;
      -t)
        run_test=true
        ;;
      clean)
        if [ -v DEBUG ]; then
          printd='-print'
        else
          printd=
        fi

        if [[ -n $2 ]]; then
          find $DOWNLOADS/* -maxdepth 0 -type f -name "*$2*" $printd -exec rm -rf {} \;
          find $LOGS/*$2* -maxdepth 0 -type d -exec rm -rf {} \;
          find $ROOT -name "*$2*" -prune $printd -exec rm -rf {} \;
          find $SOURCES/*$2* -type d -prune $printd -exec rm -rf {} \;
        else
          find $DOWNLOADS/* -maxdepth 0 \( -name '*.tar.gz' -o -name '*.zip' \) $printd -exec rm -rf {} \;
          find $ROOT/* -maxdepth 0 -type d $printd -exec rm -rf {} \;
          find $SOURCES/* -maxdepth 0 -type d $printd -exec rm -rf {} \;
        fi
        exit 0
        ;;
    esac

    shift
  done
}

is_installed() {
    local ver_pattern=$1
    local ver_command=$2
    # TODO: solve -v and -n not working leaving $ver_command unset/empty
            # foo() { 
            # arg1=$1
            # arg2=$2
            # if [[ -n arg1 ]] && [[ -n arg2 ]]; then
            # printf '%s\n' $arg1 $arg2  
            # fi
            # }

    # Try parsing some version-y output directly from program
    if [ -v $ver_pattern ]; then
      s=$(eval "$VER_COMMAND 2>&1")
      if [[ $s == *$VER_PATTERN* ]]; then
        echo "Skipped, already installed"
        return 0
      fi
    fi

    if [ -v VER_PATTERN ]; then
    # Try pkg-config first
    if {
      type pkg-config >/dev/null && 
      pkg-config --exists $VER_PATTERN
    }; then
      echo "Skipped, already installed ${PLATFORM_OS}_${ARCH}"
      return 0
    fi


  fi

}

alias xc=_exec
alias xl=exec_and_log

