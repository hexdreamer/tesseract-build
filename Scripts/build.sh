#!/bin/zsh

# Set paths one dir up, relative to this running build.sh script
SCRIPT=$0:A
BASEDIR=${SCRIPT%/Scripts/build.sh}

Downloads=$BASEDIR/Downloads
Root=$BASEDIR/Root
Sources=$BASEDIR/Sources

# PATH=/Users/kenny/Projects/Tesseract/Root/bin:$PATH
export PATH=$Root/bin:$PATH

# Handy little substitution for splitting PATH into lines
# echo ${PATH//:/\\n}  # | grep $Root

err() {
  echo "$(date +'%Y-%m-%dT%H:%M:%S%z') ERROR $*" >&2
}


while [ $# -gt 0 ]; do
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
      find "$Downloads" -name '*.tar.gz' -print0 | xargs -0 rm -rf
      find "$Root" -type d -depth 1 -print0 | xargs -0 rm -rf
      find "$Sources" -type d -depth 1 -print0 | xargs -0 rm -rf

      ls -l "$Root" "$Downloads" "$Sources"
      exit 0
      ;;
  esac

  shift
done

download_extract_install() {
  local url="$1"
  shift
  local name="$1"
  shift
  local targz="$1"
  shift

  # Default value
  local dir_name="$name"

  while [ $# -gt 0 ]; do
    case "$1" in
      --ver-command)
        shift
        local ver_command=$1
        ;;
      --ver-pattern)
        shift
        local ver_pattern=$1
        ;;
      --flags)
        shift
        local config_flags=$1
        ;;
      --dir-name)
        # Override default
        shift
        local dir_name=$1
        ;;
      --pre-config)
        shift
        local pre_config=$1
        ;;
    esac
    shift
  done

  print "\n======== $name ========"
  if [ -n "$ver_pattern" ]; then
    # Try pkg-config first
    if pkg-config --exists "$ver_pattern"; then
      echo "Skipped, already installed"
      return 0
    fi

    # Try parsing some version-y output from program
    if [ -n "$ver_command" ]; then
      s=$(eval "$ver_command 2>&1")
      if [[ $s == *${ver_pattern}* ]]; then
        echo "Skipped, already installed"
        return 0
      fi
    fi
  fi

  local downloadPath="$Downloads/$targz"
  if [ -e "$downloadPath" ]; then
    echo "Skipped download for $targz, found cached in Downloads."
  else
    print -n "Downloading $url..."
    curl -L -s "$url" --output "$downloadPath"
    print " done."
  fi

  print -n "Extracting $downloadPath..."
  tar -zxf "$downloadPath" --directory "$Sources"
  print " done."

  dir_name="$Sources/$dir_name"
  cd "$dir_name" || {
    err " Failed to cd to $dir_name"
    exit 1
  }

  if [ -n "$pre_config" ]; then
    if ! "$pre_config" >_pre_config.log 2>_err; then
      err "$pre_config:" "$(cat _err)"
      exit 1
    fi
  fi

  print -n "Configuring..."
  if [ -n "$config_flags" ]; then
    print -n " with flags $config_flags..."
    if ! ./configure --prefix="$Root" "$config_flags" >_config.log 2>_err; then
      error "./configure --prefix=\"$Root\" \"$config_flags\":" "$(cat _err)"
      exit 2
    fi
  else
    if ! ./configure --prefix="$Root" >_config.log 2>_err; then
      err "./configure --prefix=\"$Root\":" "$(cat _err)"
      exit 2
    fi
  fi

  print -n " making..."
  if [ -n "$run_test" ] && make -n check &> /dev/null; then
      print -n " running tests..."
      if ! make check>_build.log 2>_err; then
        err "Making & testing:" "$(cat _err)"
        exit 1
      fi
  else
      if ! make >_build.log 2>_err; then
        err "Making:" "$(cat _err)"
        exit 1
      fi
  fi

  print -n " installing..."
  if ! make install >_install.log 2>_err; then
    err "Installing:" "$(cat _err)"
    exit 1
  fi
  print " done."
}

# PKG-CONFIG -- https://www.freedesktop.org/wiki/Software/pkg-config/
name=pkg-config-0.29.2
targz="$name.tar.gz"

download_extract_install \
  "https://pkg-config.freedesktop.org/releases/$targz" \
  "$name" \
  "$targz" \
  "$ver_pattern" \
  --flags "--with-internal-glib" \
  --ver-command "$Root/bin/pkg-config --version" \
  --ver-pattern 0.29.2

# AUTOCONF -- https://www.gnu.org/software/autoconf/
name=autoconf-2.69
targz=$name.tar.gz

download_extract_install \
  "http://ftp.gnu.org/gnu/autoconf/$targz" \
  "$name" \
  "$targz" \
  --ver-command "$Root/bin/autoconf --version" \
  --ver-pattern "2.69"

# AUTOMAKE -- https://www.gnu.org/software/automake/
name=automake-1.16
targz="$name.tar.gz"

download_extract_install \
  "http://ftp.gnu.org/gnu/automake/$targz" \
  "$name" \
  "$targz" \
  --ver-command "$Root/bin/automake --version" \
  --ver-pattern "1.16"

# LIBTOOL -- https://www.gnu.org/software/libtool/
name=libtool-2.4.6
targz=$name.tar.gz

download_extract_install \
  "http://ftp.gnu.org/gnu/libtool/$targz" \
  "$name" \
  "$targz" \
  --ver-command "$Root/bin/libtool --version" \
  --ver-pattern "2.4.6"

# LEPTONICA -- https://github.com/DanBloomberg/leptonica
name=leptonica-1.79.0
targz="$name.tar.gz"

download_extract_install \
  "https://github.com/DanBloomberg/leptonica/releases/download/1.79.0/$targz" \
  "$name" \
  "$targz" \
  --ver-command "xtractprotos -h" \
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
