#! /bin/zsh -f

# `set -x` turns on debugging, `set +x` turns it off 
# set -x

# Relative to this running script named 'build.sh'...
scriptname=$0:A
scriptsdir=${scriptname%/build_all.sh}



# download_extract_install 'autoconf'
# download_extract_install 'automake'
# download_extract_install 'pkgconfig'
# download_extract_install 'libtool'
# download_extract_install 'zlib'

zsh $scriptsdir/build_libjpeg.sh
zsh $scriptsdir/build_libpng.sh

# download_extract_install 'libtiff'

# download_extract_install 'leptonica'
# download_extract_install 'tesseract'
