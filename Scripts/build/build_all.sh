#!/bin/zsh -f

# We thought zlib was required, but it appears not to be.  It's hidden as 
# .build_zlib.sh, and is commented out in the build chain.

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

  # zsh $parentdir/.build_zlib.sh clean
  exit 0
fi

# Prereqs for configuring/building Leptonica & Tesseract
zsh $parentdir/build_autoconf.sh || exit 1
zsh $parentdir/build_automake.sh || exit 1
zsh $parentdir/build_pkgconfig.sh || exit 1
zsh $parentdir/build_libtool.sh || exit 1

# zsh $parentdir/.build_zlib.sh || exit 1

# Libraries for Leptonica & Tesseract
zsh $parentdir/build_libjpeg.sh || exit 1
zsh $parentdir/build_libpng.sh || exit 1
zsh $parentdir/build_libtiff.sh || exit 1

# Leptonica is final dependency for Tesseract
zsh $parentdir/build_leptonica.sh || exit 1

# The last library you need for Xcode
zsh $parentdir/build_tesseract.sh || exit 1
