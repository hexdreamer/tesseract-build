#!/bin/zsh -f

# `set -x` prints debug messages from the shell, `set +x` turns it off
# set -x

scriptpath=$0:A
parentdir=${scriptpath%/*}

if [[ -n $1 ]] && [[ $1 == 'clean-all' ]]; then
  zsh $parentdir/build_autoconf.sh clean
  zsh $parentdir/build_automake.sh clean
  zsh $parentdir/build_pkgconfig.sh clean
  zsh $parentdir/build_libtool.sh clean
  zsh $parentdir/build_libjpeg.sh clean
  zsh $parentdir/build_libpng.sh clean
  zsh $parentdir/build_libtiff.sh clean
  zsh $parentdir/build_leptonica.sh clean
  zsh $parentdir/build_tesseract.sh clean
  exit 0
fi

# Prereqs for configuring/building Leptonica & Tesseract
zsh $parentdir/build_autoconf.sh || exit 1
zsh $parentdir/build_automake.sh || exit 1
zsh $parentdir/build_pkgconfig.sh || exit 1
zsh $parentdir/build_libtool.sh || exit 1

# Libraries for Leptonica & Tesseract
zsh $parentdir/build_libjpeg.sh || exit 1
zsh $parentdir/build_libpng.sh || exit 1
zsh $parentdir/build_libtiff.sh || exit 1

# Leptonica is final dependency for Tesseract
zsh $parentdir/build_leptonica.sh || exit 1

# The last library you need for Xcode
zsh $parentdir/build_tesseract.sh || exit 1
