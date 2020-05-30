#!/bin/zsh -f

# AUTOMAKE -- https://www.gnu.org/software/automake/
export NAME='automake-1.16'
export TARGZ="$NAME.tar.gz"
export URL="http://ftp.gnu.org/gnu/automake/$TARGZ"
export VER_COMMAND="$ROOT/bin/automake --version" 
export VER_PATTERN='1.16'
export TARGETS=('x86')

x86() {
    export CONFIG_CMD='../configure'
}
