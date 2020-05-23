#! /bin/zsh -f

# Set paths one dir up, relative to this running build.sh script
readonly PROGNAME=$0:A
readonly ARGS=("$@")
readonly ABORT_BUILD=21

readonly SCRIPTSDIR=${PROGNAME%/build.sh}
readonly PROJECTDIR=${SCRIPTSDIR%/Scripts}
readonly DOWNLOADS=$PROJECTDIR/Downloads
readonly ROOT=$PROJECTDIR/Root
readonly SOURCES=$PROJECTDIR/Sources

LOG_DIR="$PROJECTDIR/Logs"

err() {
  # $(date +"%y/%m/%d-%H:%M:%S")
  echo "ERROR $*" >&2
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
  local log_out="${LOG_DIR}/${pkgname}/${step}.out"
  local log_err="${LOG_DIR}/${pkgname}/${step}.err"

  local _status=

  if ! [[ -d ${LOG_DIR}/${pkgname} ]]; then
    mkdir -p "${LOG_DIR}/${pkgname}"
  fi

  "${@:3}" >"$log_out" 2>"$log_err"
  _status=$?
  if [ $_status -ne 0 ]; then
    err "runing" "${@:3}" >&2
    err "see $log_err for more details" >&2
    return "$_status"
  fi

  return 0
}

config_make_install() {
  local target=$1

  print -n "$target "

  # Execute config-function to export variables
  $target

  if ! [ -d $target ]; then
    mkdir $target
  fi

  cd $target || exit

  exec_args=(
    $NAME
    "3_${target}_config"
    $CONFIG_CMD
    $CONFIG_FLAGS
    "--prefix=$ROOT"
  )
  exec_and_log $exec_args

  print -n " making..."
  if [[ -n "$run_test" ]] && make -n check &>/dev/null; then
    print -n " running tests..."
    exec_and_log "${NAME}" "4_${target}_make" make check
  else
    exec_and_log "${NAME}" "4_${target}_make" make
  fi

  print -n " installing..."
  exec_and_log "${NAME}" "5_${target}_install" make install
  print " done."
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
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
      build)
        main
        exit 0
        ;;
      clean)
        if [ -n "$DEBUG" ]; then
          printd='-print'
        else
          printd=
        fi

        printd='-print'
        if [[ -n "$2" ]]; then
          # find $DOWNLOADS/* -maxdepth 0 -type f -name "*$2*" $printd -exec rm -rf {} \;
          find $LOG_DIR/*$2* -maxdepth 0 -type d -exec rm -rf {} \;
          find $ROOT -name "*$2*" -prune $printd -exec rm -rf {} \;
          find $SOURCES/*$2* -type d \( -name 'ios_*' -o -name 'macos_*' \) -prune $printd -exec rm -rf {} \;
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

download_extract_install() {
  local NAME=
  local TARGZ=
  local URL=
  local VER_COMMAND=
  local VER_PATTERN=
  local DIR_NAME=
  local PRE_CONFIG=
  local CONFIG_CMD=
  local CONFIG_FLAGS=
  local TARGETS=

  # shellcheck source=/dev/null
  source "${SCRIPTSDIR}/configs/${1}.sh"

  local DOWNLOAD_TGZ="$DOWNLOADS/$TARGZ"

  # Default value

  # while [[ $# -gt 0 ]]; do
  #   case "$1" in
  #     --ver-command)
  #       local VER_COMMAND=$2
  #       shift
  #       ;;
  #     --ver-pattern)
  #       local VER_PATTERN=$2
  #       shift
  #       ;;
  #     --flags)
  #       local config_flags=$2
  #       shift
  #       ;;
  #     --dir-name)
  #       # Override default
  #       local DIR_NAME=$2
  #       shift
  #       ;;
  #     --pre-config)
  #       local pre_config=$2
  #       shift
  #       ;;
  #   esac
  #   shift
  # done


  if [ -z "$DIR_NAME" ]; then
    DIR_NAME=$NAME
  fi

  pkg_dir="$SOURCES/$DIR_NAME"

  print "\n======== $NAME ========"
  if [ -n "$VER_PATTERN" ]; then
    # Try pkg-config first
    if {
      type pkg-config >/dev/null && 
      pkg-config --exists "$VER_PATTERN"
    }; then
      echo "Skipped, already installed"
      return 0
    fi

    # Try parsing some version-y output directly from program
    if [[ -n "$VER_COMMAND" ]]; then
      s=$(eval "$VER_COMMAND 2>&1")
      if [[ $s == *$VER_PATTERN* ]]; then
        echo "Skipped, already installed"
        return 0
      fi
    fi
  fi

  if [[ -e "$DOWNLOAD_TGZ" ]]; then
    echo "Skipped download, using cached $TARGZ in Downloads."
  else
    print -n "Downloading..."
    exec_and_log "${NAME}" "0_curl" curl -L -f "$URL" --output "$DOWNLOAD_TGZ"
    print " done."
  fi

  if [ -d $pkg_dir ]; then
    echo "Skipped extract of TGZ, using cached $pkg_dir in Sources."
  else
    print -n "Extracting..."
    exec_and_log "${NAME}" "1_tar" tar -zxf "$DOWNLOAD_TGZ" --directory "$SOURCES"
    print " done."
  fi

  cd  $pkg_dir || {
    err "Failed to cd to $pkg_dir"
    exit 1
  }

  if [[ -n "$PRE_CONFIG" ]]; then
    print -n "Preconfiguring..."
    exec_and_log "${NAME}" "2_preconfig" "$PRE_CONFIG"
    print " done."
  fi

  for target in $TARGETS; do
    config_make_install $target

    cd $pkg_dir || exit

    # source "${SCRIPTSDIR}/configs/common.sh"
    # unset_build_configs
  done
}

main() {
  parse_args "${ARGS[@]}"
  _status=$?
  if [[ _status -eq $ABORT_BUILD ]]; then
    return 0
  fi

  export PATH="$ROOT/bin:$PATH"

  download_extract_install "autoconf"
  download_extract_install "automake"
  download_extract_install "pkgconfig"
  
  # For some reason, this isn't being made and install of the PC files are failing
  # if ! [ -d $ROOT/lib/pkgconfig ]; then
  #   mkdir $ROOT/lib/pkgconfig
  # fi

  download_extract_install "libtool"
  download_extract_install "zlib"
  download_extract_install "libjpeg"
  download_extract_install "libpng"
  download_extract_install "libtiff"

  exit 1

  # LEPTONICA -- https://github.com/DanBloomberg/leptonica
  name=leptonica-1.79.0
  targz="$name.tar.gz"

  download_extract_install \
    "https://github.com/DanBloomberg/leptonica/releases/download/1.79.0/$targz" \
    "$name" \
    "$targz" \
    --ver-pattern "lept >= 1.79.0"

  # TESSERACT OCR -- https://github.com/tesseract-ocr/tesseract
  name=tesseract-4.1.1
  targz="$name.tar.gz"

  download_extract_install \
    "https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz" \
    "$name" \
    "$targz" \
    --pre-config "./autogen.sh" \
    --ver-pattern "tesseract >= 4.1.1"
}

main
