#!/bin/zsh -f

export NAME='zlib-1.2.11'
export TARGZ="$NAME.tar.gz"
export URL="https://sourceforge.net/projects/libpng/files/zlib/1.2.11/$TARGZ/download"
export VER_PATTERN='zlib >= 1.2.11'
export TARGETS=('x86')

x86() {
    export CONFIG_CMD='../configure'
}

