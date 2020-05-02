#!/bin/zsh

# Set paths relative to this running build.sh script
buildScript=$0:A
ScriptsDir=${buildScript%/build.sh}
Base=${ScriptsDir%/Scripts}
Downloads=$Base/Downloads
Root=$Base/Root
Sources=$Base/Sources

# PATH=/Users/kenny/Projects/Tesseract/Root/bin:$PATH
export PATH=$Root/bin:$PATH

# Handy little substitution for splitting PATH into lines
# echo ${PATH//:/\\n}  # | grep $Root

function download_extract_install() {
    _url=$1
    _name=$2
    _targz=$3
    _flags=$4
    _ver_pattern=$5
    _ver_command=$6

    s=$(eval "$_ver_command")
    if [[ $s == *${_ver_pattern}* ]]; then
        print "Skipped $_name, already installed"
        return
    fi

    if [[ -e $Downloads/$_targz ]]; then
        print "Skipped download for $_targz, found cached in Downloads."
    else
        print -n "Downloading and extracting $_url..."
        curl -L -s "$_url" --output "$Downloads/$_targz"
        tar -zxf "$Downloads/$_targz" --directory "$Sources"
        print " done."
    fi

    print -n "Configuring, making, installing $_name..."
    cd "$Sources/$_name" || { echo " Failed to cd to $Sources/$_name"; exit 1; }
    ./configure --prefix="$Root" "$_flags" >_build.log 2>_error.log
    make >>_build.log 2>>_error.log
    make install >>_build.log 2>>_error.log
    print " done."
}

# AUTOCONF -- https://www.gnu.org/software/autoconf/
name=autoconf-2.69
targz=$name.tar.gz
flags=" "
ver_pattern=2.69
ver_command="$Root/bin/autoconf --version"

args=(
    "http://ftp.gnu.org/gnu/autoconf/$targz"
    "$name"
    "$targz"
    "$flags"
    "$ver_pattern"
    "$ver_command"
)
download_extract_install "$args"


# AUTOMAKE -- https://www.gnu.org/software/automake/
name=automake-1.16
targz="$name.tar.gz"
flags=" "
ver_pattern=1.16
ver_command="$Root/bin/automake --version"

args=(
    "http://ftp.gnu.org/gnu/automake/$targz"
    "$name"
    "$targz"
    "$flags"
    "$ver_pattern"
    "$ver_command"
)
download_extract_install "$args"

# LIBTOOL -- https://www.gnu.org/software/libtool/
name=libtool-2.4.6
targz=$name.tar.gz
flags=" "
ver_pattern=2.4.6
ver_command="$Root/bin/libtool --version"

args=(
    "http://ftp.gnu.org/gnu/libtool/$targz"
    "$name"
    "$targz"
    "$flags"
    "$ver_pattern"
    "$ver_command"
)
download_extract_install "$args"

# PKG-CONFIG -- https://www.freedesktop.org/wiki/Software/pkg-config/
name=pkg-config-0.29.2
targz="$name.tar.gz"
flags="--with-internal-glib"
ver_pattern=0.29.2
ver_command="$Root/bin/pkg-config --version"

args=(
    "https://pkg-config.freedesktop.org/releases/$targz"
    "$name"
    "$targz"
    "$flags"
    "$ver_pattern"
    "$ver_command"
)
download_extract_install

exit 1
# ./configure --prefix /Users/kenny/Projects/Tesseract/Root --with-internal-glib

# https://github.com/DanBloomberg/leptonica
curl -L https://github.com/DanBloomberg/leptonica/releases/download/1.79.0/leptonica-1.79.0.tar.gz --output leptonica-1.79.0.tar.gz
./configure --prefix /Users/kenny/Projects/Tesseract/Root

# Optionally libpng, libjpeg, libtiff (Already exists on system?)

# https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz
curl -L https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz --output tesseract-4.1.1.tar.gz
./autogen.sh
./configure --prefix /Users/kenny/Projects/Tesseract/Root
