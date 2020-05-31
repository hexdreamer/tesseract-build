#! /bin/zsh -f

# `set -x` turns on debugging, `set +x` turns it off 
# set -x

# Relative to this running script named 'build_all.sh'...
scriptname=$0:A
scriptsdir=${scriptname%/build_all.sh}

if [[ $1 == '-t' ]]; then
    cmd=(time zsh)
else
    cmd=(zsh)
fi

$cmd $scriptsdir/build_autoconf.sh
$cmd $scriptsdir/build_automake.sh
$cmd $scriptsdir/build_pkgconfig.sh
$cmd $scriptsdir/build_libtool.sh
$cmd $scriptsdir/build_zlib.sh

$cmd $scriptsdir/build_libjpeg.sh
$cmd $scriptsdir/build_libpng.sh
$cmd $scriptsdir/build_libtiff.sh

$cmd $scriptsdir/build_leptonica.sh
$cmd $scriptsdir/build_tesseract.sh
