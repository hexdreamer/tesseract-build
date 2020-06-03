#!/bin/zsh -f

# `set -x` turns on debugging, `set +x` turns it off
# set -x

scriptpath=$0:A
parentdir=${scriptpath%/*}

if [[ -n $1 ]] && [[ $1 == 'clean-all' ]]; then
  zsh $parentdir/build_autoconf.sh clean
  zsh $parentdir/build_automake.sh clean
  zsh $parentdir/build_pkgconfig.sh clean
  zsh $parentdir/build_libtool.sh clean
  zsh $parentdir/build_zlib.sh clean
  zsh $parentdir/build_libjpeg.sh clean
  zsh $parentdir/build_libpng.sh clean
  zsh $parentdir/build_libtiff.sh clean
  zsh $parentdir/build_leptonica.sh clean
  zsh $parentdir/build_tesseract.sh clean
  exit 0
fi

# Prereqs for configuring/building Leptonica & Tesseract
zsh $parentdir/build_autoconf.sh
zsh $parentdir/build_automake.sh
zsh $parentdir/build_pkgconfig.sh
zsh $parentdir/build_libtool.sh

# Libraries for Leptonica & Tesseract
zsh $parentdir/build_zlib.sh
zsh $parentdir/build_libjpeg.sh
zsh $parentdir/build_libpng.sh
zsh $parentdir/build_libtiff.sh

# Leptonica is final dependency for Tesseract
zsh $parentdir/build_leptonica.sh

# The last library you need for Xcode
zsh $parentdir/build_tesseract.sh
