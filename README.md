PATH=/Users/kenny/Projects/Tesseract/Root/bin:$PATH
export PATH

blah

# https://www.gnu.org/software/autoconf/
curl -L http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz --output autoconf-2.69.tar.gz
./configure --prefix /Users/kenny/Projects/Tesseract/Root

# https://www.gnu.org/software/automake/
curl -L http://ftp.gnu.org/gnu/automake/automake-1.16.tar.gz --output automake-1.16.tar.gz
./configure --prefix /Users/kenny/Projects/Tesseract/Root

# https://www.gnu.org/software/libtool/
curl -L http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz --output libtool-2.4.6.tar.gz
./configure --prefix /Users/kenny/Projects/Tesseract/Root

# https://www.freedesktop.org/wiki/Software/pkg-config/
curl -L https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz --output pkg-config-0.29.2.tar.gz
./configure --prefix /Users/kenny/Projects/Tesseract/Root --with-internal-glib

# https://github.com/DanBloomberg/leptonica
curl -L https://github.com/DanBloomberg/leptonica/releases/download/1.79.0/leptonica-1.79.0.tar.gz --output leptonica-1.79.0.tar.gz
./configure --prefix /Users/kenny/Projects/Tesseract/Root

# Optionally libpng, libjpeg, libtiff (Already exists on system?)

# https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz
curl -L https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz --output tesseract-4.1.1.tar.gz
./autogen.sh
./configure --prefix /Users/kenny/Projects/Tesseract/Root

