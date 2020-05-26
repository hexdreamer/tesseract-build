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

  # Leaving this group of vars in quotes because shunit2 tests run with
  # set shwordsplit set, which then requires zsh to quote all paths just like bash
  if ! [ -d "${LOG_DIR}/${pkgname}" ]; then
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

  # Execute config-function to export variables
  $target

  if [ -v VER_PATTERN ]; then
    # Try pkg-config first
    if {
      type pkg-config >/dev/null && 
      pkg-config --exists $VER_PATTERN
    }; then
      echo "Skipped, already installed ${PLATFORM_OS}_${ARCH}"
      return 0
    fi

    # Try parsing some version-y output directly from program
    if [ -v VER_COMMAND ]; then
      s=$(eval "$VER_COMMAND 2>&1")
      if [[ $s == *$VER_PATTERN* ]]; then
        echo "Skipped, already installed"
        return 0
      fi
    fi
  fi

  if [ -v PRECONFIG ]; then
    if [ -f .preconfiged ]; then
      echo 'Skipped, already preconfigured'
    else
      print -n "Preconfiguring..."
      if ! exec_and_log ${NAME} '2_preconfig' $PRECONFIG; then
        print 'aborting.'
        exit 1
      fi
      print " done."
      touch .preconfiged
    fi
  fi
  
  print -n "$target "

  if ! [ -d $target ]; then
    mkdir $target
  fi

  cd $target || exit

  # Since GNU packages don't define these vars
  if [[ -v PLATFORM_OS && -v ARCH ]]; then
    prefix=$ROOT/${PLATFORM_OS}_${ARCH}
  else
    prefix=$ROOT
  fi

  print -n 'Configuring...'
  exec_args=(
    $NAME
    "3_${target}_config"
    $CONFIG_CMD
    $CONFIG_FLAGS
    "--prefix=$prefix"
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

lipo_libs() {
  if ! [ -d ${ROOT}/lib ]; then
    mkdir -p ${ROOT}/lib
  fi

  if [ -v IOS_TARGETS ]; then
    cd $ROOT || exit
    local libs=()
    for ios_target in $IOS_TARGETS
    do
      libs=($libs $ios_target/lib/${LIBNAME}.a)
    done

    xcrun_args=(
      $NAME
      "6_ios_lipo"
      xcrun
      lipo
      $libs
      -create
      -output
      $ROOT/lib/${LIBNAME}.a
    )

    print -n 'Lipo-ing iOS libs...'
    exec_and_log $xcrun_args
    print ' done.'
  fi

  if [ -v MACOS_TARGETS ]; then
    cd $ROOT || exit
    local libs=()
    for macos_target in $MACOS_TARGETS

    do
      libs=($libs $macos_target/lib/${LIBNAME}.a)
    done

    xcrun_args=(
      $NAME
      "6_macos_lipo"
      lipo
      $libs
      -create
      -output
      $ROOT/lib/${LIBNAME}-macos.a
    )

    print -n 'Lipo-ing macOS libs...'
    exec_and_log $xcrun_args
    print ' done.'
  fi
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
  # shellcheck source=/dev/null
  source ${SCRIPTSDIR}/configs/unset_all.sh
  # shellcheck source=/dev/null
  source ${SCRIPTSDIR}/configs/${1}.sh

  local download_tgz=$DOWNLOADS/$TARGZ
  local pkg_dir=

  if ! [ -v DIR_NAME ]; then
    DIR_NAME=$NAME
  fi

  pkg_dir=$SOURCES/$DIR_NAME

  print "\n======== $NAME ========"

  if [ -e $download_tgz ]; then
    echo "Skipped download, using cached $TARGZ in Downloads."
  else
    print -n "Downloading..."
    exec_and_log "${NAME}" "0_curl" curl -L -f "$URL" --output "$download_tgz"
    print " done."
  fi

  if [ -d $pkg_dir ]; then
    echo "Skipped extract of TGZ, using cached $pkg_dir in Sources."
  else
    print -n "Extracting..."
    exec_and_log "${NAME}" "1_tar" tar -zxf "$download_tgz" --directory "$SOURCES"
    print " done."
  fi

  cd  $pkg_dir || {
    err "Failed to cd to $pkg_dir"
    exit 1
  }

  for target in $TARGETS; do
    config_make_install $target

    # Reset: cd back to pkg_dir before running next target
    cd $pkg_dir || exit
  done

  lipo_libs
}

main() {
  parse_args ${ARGS[@]}
  _status=$?

  if [ -v DEBUG ]; then
    set -x
  fi

  if [ $_status -eq $ABORT_BUILD ]; then
    return 0
  fi

  export PATH=$ROOT/bin:$PATH

  download_extract_install 'autoconf'
  download_extract_install 'automake'
  download_extract_install 'pkgconfig'
  download_extract_install 'libtool'
  download_extract_install 'zlib'

  download_extract_install 'libjpeg'
  download_extract_install 'libpng'
  download_extract_install 'libtiff'

  download_extract_install 'leptonica'
  download_extract_install 'tesseract'
}

main
