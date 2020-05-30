#! /bin/zsh -f

# `set -x` turns on debugging, `set +x` turns it off 
# set -x

# Relative to this running script named 'build.sh'...
scriptname=$0:A
scriptsdir=${scriptname%/build_all.sh}



zsh $scriptsdir/build_autoconf.sh
zsh $scriptsdir/build_automake.sh
# download_extract_install 'pkgconfig'
# download_extract_install 'libtool'
zsh $scriptsdir/build_zlib.sh

zsh $scriptsdir/build_libjpeg.sh
zsh $scriptsdir/build_libpng.sh
zsh $scriptsdir/build_libtiff.sh

# download_extract_install 'leptonica'
# download_extract_install 'tesseract'
