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


func download_extract() {
    _url=$1
    _name=$2
    _targz=$3
    _flags=$4

    if [[ -a $Downloads/$_targz ]]; then
        print "Skipped download for $_targz, found cached in Downloads."
    else 
        print -n "Downloading and extracting $_url..."
        curl -L -s $_url --output $Downloads/$_targz
        tar -zxf $Downloads/$_targz --directory $Sources
        print " done."
    fi

    # if [[ -d $Sources/$_name ]]; then
    #     print "Skipped config/make/install for $_name, found cached in Sources"
    # else
    print -n "Configuring, making, installing $_name..."
    cd $Sources/$_name
    ./configure --prefix=$Root $_flags > _build.log 2>_error.log
    make >> _build.log 2>>_error.log
    make install >> _build.log 2>>_error.log
    print " done."
    # fi
}



# AUTOCONF -- https://www.gnu.org/software/autoconf/
name=autoconf-2.69
targz=$name.tar.gz
args=(
    http://ftp.gnu.org/gnu/autoconf/$targz
    $name
    $targz
)

download_extract $args

# AUTOMAKE -- https://www.gnu.org/software/automake/
name=automake-1.16
targz=$name.tar.gz
args=(
    http://ftp.gnu.org/gnu/automake/$targz
    $name
    $targz
)

download_extract $args

# LIBTOOL -- https://www.gnu.org/software/libtool/
name=libtool-2.4.6
targz=$name.tar.gz
args=(
    http://ftp.gnu.org/gnu/libtool/$targz
    $name
    $targz
)

download_extract $args

# PKG-CONFIG -- https://www.freedesktop.org/wiki/Software/pkg-config/
name=pkg-config-0.29.2
targz=$name.tar.gz
args=(
    https://pkg-config.freedesktop.org/releases/$targz
    $name
    $targz
    "--with-internal-glib"
)

download_extract $args
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
