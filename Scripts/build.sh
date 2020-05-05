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

while [ $# -gt 0 ]
do
    case "$1" in
    -h)
        echo
        echo Download and build Tesseract OCR, and all tooling
        echo
        echo '  -d        `set -x` for debugging'
        echo '  -h        print this message'
        echo
        echo '  clean     remove all artifacts from Root, Downloads, and Sources'
        echo

        exit 1
        ;;
    -d)
        set -x
        ;;

    clean)
        find "$Downloads" -name '*.tar.gz' -print0 | xargs -0 rm -rf
        find "$Root" -type d -depth 1 -print0 | xargs -0 rm -rf
        find "$Sources" -type d -depth 1 -print0 | xargs -0 rm -rf

        ls -l "$Root" "$Downloads" "$Sources"
        exit 0
    esac

    shift
done


download_extract_install() {
    _url=$1
    _name=$2
    _targz=$3
    _ver_pattern=$4
    _ver_command=$5
    _config_flags=$6
    _dir_name=$7

    s=$(eval "$_ver_command 2>&1")
    if [[ $s == *${_ver_pattern}* ]]; then
        echo "Skipped $_name, already installed"
        return 1
    fi

    if [[ -e $Downloads/$_targz ]]; then
        echo "Skipped download for $_targz, found cached in Downloads."
    else
        print -n "Downloading $_url..."
        curl -L -s "$_url" --output "$Downloads/$_targz"
        print " done."
    fi

    print -n "Extracting $Downloads/$_targz..."
    tar -zxf "$Downloads/$_targz" --directory "$Sources"
    print " done."

    if [[ -n $_dir_name ]]; then
        source_dir="$Sources/$_dir_name"
    else
        source_dir="$Sources/$_name"
    fi
    cd "$source_dir" || { echo " Failed to cd to $source_dir"; exit 1; }

    print -n "Configuring, making, installing $_name..."

    if [[ -n $_config_flags ]]; then
        print -n " with flags $_config_flags..."
        ./configure --prefix="$Root" "$_config_flags" >_build.log 2>_error.log
    else
        ./configure --prefix="$Root" >_build.log 2>_error.log
    fi

    make >>_build.log 2>>_error.log
    make install >>_build.log 2>>_error.log

    print " done."
}

# AUTOCONF -- https://www.gnu.org/software/autoconf/
name=autoconf-2.69
targz=$name.tar.gz
ver_pattern=2.69
ver_command="$Root/bin/autoconf --version"

download_extract_install \
    "http://ftp.gnu.org/gnu/autoconf/$targz" \
    "$name" \
    "$targz" \
    "$ver_pattern" \
    "$ver_command" \


# AUTOMAKE -- https://www.gnu.org/software/automake/
name=automake-1.16
targz="$name.tar.gz"
ver_pattern=1.16
ver_command="$Root/bin/automake --version"

download_extract_install \
    "http://ftp.gnu.org/gnu/automake/$targz" \
    "$name" \
    "$targz" \
    "$ver_pattern" \
    "$ver_command"


# LIBTOOL -- https://www.gnu.org/software/libtool/
name=libtool-2.4.6
targz=$name.tar.gz
ver_pattern=2.4.6
ver_command="$Root/bin/libtool --version"

download_extract_install \
    "http://ftp.gnu.org/gnu/libtool/$targz" \
    "$name" \
    "$targz" \
    "$ver_pattern" \
    "$ver_command" \
    "$flags" \


# PKG-CONFIG -- https://www.freedesktop.org/wiki/Software/pkg-config/
name=pkg-config-0.29.2
targz="$name.tar.gz"
ver_pattern=0.29.2
ver_command="$Root/bin/pkg-config --version"
flags="--with-internal-glib"

download_extract_install \
    "https://pkg-config.freedesktop.org/releases/$targz" \
    "$name" \
    "$targz" \
    "$ver_pattern" \
    "$ver_command" \
    "$flags"


# LEPTONICA -- https://github.com/DanBloomberg/leptonica
name=leptonica-1.79.0
targz="$name.tar.gz"
ver_pattern="v. 1.5"
ver_command="xtractprotos -h"

download_extract_install \
    "https://github.com/DanBloomberg/leptonica/releases/download/1.79.0/$targz" \
    "$name" \
    "$targz" \
    "$ver_pattern" \
    "$ver_command" \


# Optionally libpng, libjpeg, libtiff (Already exists on system?)
# LIBJPEG -- http://ijg.org/
name=jpegsrc.v9d
targz="$name.tar.gz"
ver_pattern="abc"
ver_command="unknown"
flags=""
dir_name=jpeg-9d

download_extract_install \
    "http://www.ijg.org/files/$targz" \
    "$name" \
    "$targz" \
    "$ver_pattern" \
    "$ver_command" \
    "$flags" \
    "$dir_name"


# LIBTIFF -- https://gitlab.com/libtiff/libtiff
name=tiff-4.1.0
targz="$name.tar.gz"
ver_pattern="LIBTIFF, Version 4.1.0"
ver_command="tiffcmp"

download_extract_install \
    "http://download.osgeo.org/libtiff/$targz" \
    "$name" \
    "$targz" \
    "$ver_pattern" \
    "$ver_command"


# curl --remote-name --location http://download.sourceforge.net/libpng/libpng-1.6.35.tar.gz

exit 1
# https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz
curl -L https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz --output tesseract-4.1.1.tar.gz
./autogen.sh
./configure --prefix /Users/kenny/Projects/Tesseract/Root
