## Overview
This project presents you, running macOS, with a single-source-and-run script to:
1. download, build, and locally install all build tools required to build Tesseract OCR
2. download Tesseract OCR, target iOS, and build multi-architecture "fat" binaries

*Locally install* means that all build artifacts (binaries, libs, etc...) are installed under a single directory, Root.  We specifically avoid **su** privileges and mucking with your system.

## Pre-requisites
Achieving the single-source-and-run goal does require some pre-requisite work on your part.  You must have Xcode 11 and the command-line tools already installed.

#### Existing tooling, brew
This project does not attempt to be compatible with any existing tooling you may have installed.  I do not know if brew precludes any of the directions/build-steps, or vice-versa; we do not use brew.

## Kicking it off (Installing)
1. `cd` into the directory that will host the project
2. Clone this repo
       git clone https://github.com/zacharysyoung/tesseract-build.git .
3. `cd tesseract-build && Scripts/build.sh`


PATH=/Users/kenny/Projects/Tesseract/Root/bin:$PATH
export PATH

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
