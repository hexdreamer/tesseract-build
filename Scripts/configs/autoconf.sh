#!/bin/zsh -f

export NAME='autoconf-2.69'
export TARGZ="$NAME.tar.gz"
export URL="http://ftp.gnu.org/gnu/autoconf/$TARGZ"
export VER_COMMAND="$ROOT/bin/autoconf --version"
export VER_PATTERN='2.69'
export TARGETS=('x86')

x86() {
  export CONFIG_CMD='../configure'
}