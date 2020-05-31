#! /bin/zsh -f

# `set -x` turns on debugging, `set +x` turns it off 
# set -x

# Relative to this running script named 'build_all.sh'...
scriptname=$0:A
parentdir=${scriptname%/build_all.sh}

zsh $parentdir/build_autoconf.sh
zsh $parentdir/build_automake.sh
zsh $parentdir/build_pkgconfig.sh
zsh $parentdir/build_libtool.sh
zsh $parentdir/build_zlib.sh

zsh $parentdir/build_libjpeg.sh
zsh $parentdir/build_libpng.sh
zsh $parentdir/build_libtiff.sh

zsh $parentdir/build_leptonica.sh
zsh $parentdir/build_tesseract.sh
