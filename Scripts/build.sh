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
        if [[ -n "$2" ]]; then
          find "$DOWNLOADS" -name "$2*.tar.gz" -exec rm -rf {} \;
          find "$ROOT" -name "$2*" -prune -exec rm -rf {} \;
          find "$ROOT/lib/pkgconfig" -name "*$2*" -prune -exec rm -rf {} \;
          find "$SOURCES" -type d -name "$2*" -depth 1 -prune -exec rm -rf {} \;
        else
          find "$DOWNLOADS" -name '*.tar.gz' -prune -exec rm -rf {} \;
          find "$ROOT" -type d -depth 1 -prune -exec rm -rf {} \;
          find "$SOURCES" -type d -depth 1 -prune -exec rm -rf {} \;
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

  # shellcheck source=/dev/null
  source "$1"

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

  print "\n======== $NAME ========"
  if [[ -n "$VER_PATTERN" ]]; then
    # Try pkg-config first
    if pkg-config --exists "$VER_PATTERN"; then
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

    print -n " extracting..."
    exec_and_log "${NAME}" "1_tar" tar -zxf "$DOWNLOAD_TGZ" --directory "$SOURCES"

    print " done."
  fi

  if [ -z "$DIR_NAME" ]; then 
    DIR_NAME=$NAME
  fi

  cd "$SOURCES/$DIR_NAME" || {
    err "Failed to cd to $SOURCES/$DIR_NAME"
    exit 1
  }

  if [[ -n "$PRE_CONFIG" ]]; then
    print -n "Preconfiguring..."
    exec_and_log "${NAME}" "2_preconfig" "$PRE_CONFIG"
    print " done."
  fi

  
  exec_and_log "${NAME}" "3_config" ./configure --prefix="$ROOT" "${CONFIG_FLAGS}"

  print -n " making..."
  if [[ -n "$run_test" ]] && make -n check &>/dev/null; then
    print -n " running tests..."
    exec_and_log "${NAME}" "4_make" make check
  else
    exec_and_log "${NAME}" "4_make" make
  fi

  print -n " installing..."
  exec_and_log "${NAME}" "5_install" make install
  print " done."
}

main() {
  parse_args "${ARGS[@]}"
  _status=$?
  if [[ _status -eq $ABORT_BUILD ]]; then
    return 0
  fi

  export PATH="$ROOT/bin:$PATH"

  # PKG-CONFIG -- https://www.freedesktop.org/wiki/Software/pkg-config/
  name=pkg-config-0.29.2
  targz="$name.tar.gz"

  download_extract_install \
    "https://pkg-config.freedesktop.org/releases/$targz" \
    "$name" \
    "$targz" \
    --flags "--with-internal-glib" \
    --ver-command "$ROOT/bin/pkg-config --version" \
    --ver-pattern 0.29.2

  # AUTOCONF -- https://www.gnu.org/software/autoconf/
  name=autoconf-2.69
  targz=$name.tar.gz

  download_extract_install \
    "http://ftp.gnu.org/gnu/autoconf/$targz" \
    "$name" \
    "$targz" \
    --ver-command "$ROOT/bin/autoconf --version" \
    --ver-pattern "2.69"

  # AUTOMAKE -- https://www.gnu.org/software/automake/
  name=automake-1.16
  targz="$name.tar.gz"

  download_extract_install \
    "http://ftp.gnu.org/gnu/automake/$targz" \
    "$name" \
    "$targz" \
    --ver-command "$ROOT/bin/automake --version" \
    --ver-pattern "1.16"

  # LIBTOOL -- https://www.gnu.org/software/libtool/
  name=libtool-2.4.6
  targz=$NAME.tar.gz

  download_extract_install \
    "http://ftp.gnu.org/gnu/libtool/$targz" \
    "$name" \
    "$targz" \
    --ver-command "$ROOT/bin/libtool --version" \
    --ver-pattern "2.4.6"

  # LEPTONICA -- https://github.com/DanBloomberg/leptonica
  name=leptonica-1.79.0
  targz="$name.tar.gz"

  download_extract_install \
    "https://github.com/DanBloomberg/leptonica/releases/download/1.79.0/$targz" \
    "$name" \
    "$targz" \
    --ver-pattern "lept >= 1.79.0"

  # Optionally libpng, libjpeg, libtiff (Already exists on system?)
  # LIBJPEG -- http://ijg.org/
  name=jpegsrc.v9d
  targz="$name.tar.gz"

  download_extract_install \
    "http://www.ijg.org/files/$targz" \
    "$name" \
    "$targz" \
    --dir-name jpeg-9d \
    --ver-pattern "libjpeg >= 9.4.0"

  # LIBTIFF -- https://gitlab.com/libtiff/libtiff
  name=tiff-4.1.0
  targz="$name.tar.gz"

  download_extract_install \
    "http://download.osgeo.org/libtiff/$targz" \
    "$name" \
    "$targz" \
    --ver-pattern "libtiff-4 >= 4.1.0"

  # ZLIB --
  name=zlib-1.2.11
  targz="$name.tar.gz"

  download_extract_install \
    "https://sourceforge.net/projects/libpng/files/zlib/1.2.11/$targz/download" \
    "$name" \
    "$targz" \
    --ver-pattern "zlib >= 1.2.11"

  
  download_extract_install "libpng"

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
