#!/bin/bash -f

# LIBPNG -- http://www.libpng.org/pub/png/libpng.html

export NAME='libpng-1.6.37'
export TARGZ="$NAME.tar.gz"
export URL="https://sourceforge.net/projects/libpng/files/libpng16/1.6.37/$TARGZ/download"
export VER_COMMAND='libpng-config --version'
export VER_PATTERN='libpng >= 1.6.37'

export SDKROOT='/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk'

CFLAGS_A=(
  '-arch arm64'
  '-pipe'
  '-no-cpp-precomp'
  "-isysroot $SDKROOT"
  '-miphoneos-version-min=11.0'
  '-O2'
  '-fembed-bitcode'
)
CFLAGS="$CFLAGS_A"

CXXFLAGS_A=(
  $CFLAGS_A
  '-Wno-deprecated-register'
)
CXXFLAGS="$CXXFLAGS_A"

export CFLAGS
export CXXFLAGS

export CPPFLAGS=$CFLAGS
export LDFLAGS="-L$SDKROOT/usr/lib/"

CONFIG_FLAGS_A=(
  "CXX=$(xcode-select -p)/usr/bin/g++ --target=arm-apple-darwin64"
  "CC=$(xcode-select -p)/usr/bin/gcc --target=arm-apple-darwin64"
  '--host=arm-apple-darwin64'
  '--enable-shared=no'
  '--disable-graphics'
)
CONFIG_FLAGS="$CONFIG_FLAGS_A"
export CONFIG_FLAGS

../configure $CONFIG_FLAGS --prefix=/Users/zyoung/dev/tesseract-build/Root
