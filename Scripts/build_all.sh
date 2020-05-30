#! /bin/zsh -f

# `set -x` turns on debugging, `set +x` turns it off 
# set -x

# Relative to this running script named 'build_all.sh'...
scriptname=$0:A
scriptsdir=${scriptname%/build_all.sh}

zsh $scriptsdir/build_autoconf.sh
zsh $scriptsdir/build_automake.sh
zsh $scriptsdir/build_pkgconfig.sh
zsh $scriptsdir/build_libtool.sh
zsh $scriptsdir/build_zlib.sh

zsh $scriptsdir/build_libjpeg.sh
zsh $scriptsdir/build_libpng.sh
zsh $scriptsdir/build_libtiff.sh

zsh $scriptsdir/build_leptonica.sh
# download_extract_install 'tesseract'
