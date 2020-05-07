#!/bin/zsh -f

# Set paths one dir up, relative to this running build.sh script
readonly PROGNAME=$0:A
readonly ARGS=("$@")

readonly SCRIPTSDIR=${PROGNAME%/build.sh}
readonly PROJECTDIR=${SCRIPTSDIR%/Scripts}
readonly DOWNLOADS=$PROJECTDIR/Downloads
readonly ROOT=$PROJECTDIR/Root
readonly SOURCES=$PROJECTDIR/Sources

readonly ERR_MSG="$SCRIPTSDIR/_err"

err() {
  echo "$(date +'%Y-%m-%dT%H:%M:%S%z') ERROR $1, $(cat "$ERR_MSG")" >&2
  rm "$ERR_MSG"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h)
        echo
        echo Download and build Tesseract OCR, and all tooling
        echo
        echo '  -d        set -x for debugging'
        echo '  -h        print this message'
        echo
        echo '  clean     remove all artifacts from Root, Downloads, and Sources'
        echo

        exit 1
        ;;
      -d)
        set -x
        ;;
      -t)
        run_test=true
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
  local url="$1"
  shift
  local name="$1"
  shift
  local targz="$1"
  shift

  local download_path="$DOWNLOADS/$targz"

  # Default value
  local dir_name="$name"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ver-command)
        local ver_command=$2
        shift
        ;;
      --ver-pattern)
        local ver_pattern=$2
        shift
        ;;
      --flags)
        local config_flags=$2
        shift
        ;;
      --dir-name)
        # Override default
        local dir_name=$2
        shift
        ;;
      --pre-config)
        local pre_config=$2
        shift
        ;;
    esac
    shift
  done

  print "\n======== $name ========"
  if [[ -n "$ver_pattern" ]]; then
    # Try pkg-config first
    if pkg-config --exists "$ver_pattern"; then
      echo "Skipped, already installed"
      return 0
    fi

    # Try parsing some version-y output directly from program
    if [[ -n "$ver_command" ]]; then
      s=$(eval "$ver_command 2>&1")
      if [[ $s == *$ver_pattern* ]]; then
        echo "Skipped, already installed"
        return 0
      fi
    fi
  fi

  if [[ -e "$download_path" ]]; then
    echo "Skipped download for $targz, found cached in Downloads."
  else
    print -n "Downloading $url..."
    curl -L -s "$url" --output "$download_path"
    print " done."
  fi

  print -n "Extracting $download_path..."
  if ! tar -zxf "$download_path" --directory "$SOURCES" >"$ERR_MSG" 2>&1; then
    err "tar -zxf \"$download_path\" --directory \"$SOURCES\""
    exit 1
  fi
  print " done."

  cd "$SOURCES/$dir_name" >"$ERR_MSG" 2>&1 || {
    err "Failed to cd to $SOURCES/$dir_name"
    exit 1
  }

  if [[ -n "$pre_config" ]]; then
    if ! "$pre_config" >_pre_config.log 2>"$ERR_MSG"; then
      err "$pre_config:"
      exit 1
    fi
  fi

  print -n "Configuring..."
  if [[ -n "$config_flags" ]]; then
    print -n " with flags $config_flags..."
    if ! ./configure --prefix="$ROOT" "$config_flags" >_config.log 2>"$ERR_MSG"; then
      error "./configure --prefix=\"$ROOT\" \"$config_flags\":"
      exit 2
    fi
  else
    if ! ./configure --prefix="$ROOT" >_config.log 2>"$ERR_MSG"; then
      err "./configure --prefix=\"$ROOT\":"
      exit 2
    fi
  fi

  print -n " making..."
  if [[ -n "$run_test" ]] && make -n check &>/dev/null; then
    print -n " running tests..."
    if ! make check >_build.log 2>"$ERR_MSG"; then
      err "Making & testing:"
      exit 1
    fi
  else
    if ! make >_build.log 2>"$ERR_MSG"; then
      err "Making:"
      exit 1
    fi
  fi

  print -n " installing..."
  if ! make install >_install.log 2>"$ERR_MSG"; then
    err "Installing:"
    exit 1
  fi
  print " done."
}

main() {
  parse_args "${ARGS[@]}"
  export PATH="$ROOT/bin:$PATH"

  # PKG-CONFIG -- https://www.freedesktop.org/wiki/Software/pkg-config/
  name=pkg-config-0.29.2
  targz="$name.tar.gz"

  download_extract_install \
    "https://pkg-config.freedesktop.org/releases/$targz" \
    "$name" \
    "$targz" \
    "$ver_pattern" \
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
  targz=$name.tar.gz

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

  # LIBPNG -- http://www.libpng.org/pub/png/libpng.html
  name=libpng-1.6.37
  targz="$name.tar.gz"

  download_extract_install \
    "https://sourceforge.net/projects/libpng/files/libpng16/1.6.37/$targz/download" \
    "$name" \
    "$targz" \
    --ver-command "libpng-config --version" \
    --ver-pattern "libpng >= 1.6.37"

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
