#!/bin/zsh -f

# LIBTOOL -- https://www.gnu.org/software/libtool/

export NAME='libtool-2.4.6'
export TARGZ="$NAME.tar.gz"
export URL="http://ftp.gnu.org/gnu/libtool/$TARGZ"
export VER_COMMAND="$ROOT/bin/libtool --version"
export VER_PATTERN='2.4.6'
export TARGETS=('x86')

x86() {
    export CONFIG_CMD='../configure'
}
