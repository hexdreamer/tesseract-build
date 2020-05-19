#!/bin/bash -f

# LIBPNG -- http://www.libpng.org/pub/png/libpng.html

export NAME='libpng-1.6.37'
export TARGZ="$NAME.tar.gz"
export URL="https://sourceforge.net/projects/libpng/files/libpng16/1.6.37/$TARGZ/download"
export VER_COMMAND='libpng-config --version'
export VER_PATTERN='libpng >= 1.6.37'
export TARGETS=('ios_arm' 'ios_x86' 'mac_x86')

set_common() {
  export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/$PLATFORM"
  export LDFLAGS="-L$SDKROOT/usr/lib/"

  # CFLAGS and CXXFLAGS are concatenated to strings for downstream steps in configure/make
  CFLAGS_ARR=(
    "-arch $ARCH"
    '-pipe'
    '-no-cpp-precomp'
    "-isysroot $SDKROOT"
    "$CLANG_IVERSION"
    '-O2'
    '-fembed-bitcode'
  )

  CXXFLAGS_ARR=(
    $CFLAGS_A
    '-Wno-deprecated-register'
  )

  CFLAGS="$CFLAGS_ARR"
  export CFLAGS

  CXXFLAGS="$CXXFLAGS_ARR"
  export CXXFLAGS
  
  export CPPFLAGS=$CFLAGS

  # CONFIG_FLAGS is left as an array for exec_and_log()
  CONFIG_FLAGS=(
    "CXX=$(xcode-select -p)/usr/bin/g++ --target=$TARGET"
    "CC=$(xcode-select -p)/usr/bin/gcc --target=$TARGET"
    "--host=$TARGET"
    '--enable-shared=no'
    '--disable-graphics'
  )

  export CONFIG_FLAGS
  export CONFIG_CMD='../configure'
}

ios_arm() {
  export TARGET='arm-apple-darwin64'

  export ARCH='arm64'
  export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk'
  export CLANG_IVERSION='-miphoneos-version-min=11.0'

  set_common
}

ios_x86() {
  export TARGET='x86_64-apple-darwin'

  export ARCH='x86_64'
  export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk'
  export CLANG_IVERSION='-mios-simulator-version-min=11.0'

  set_common
}

mac_x86() {
  export TARGET='x86_64-apple-darwin'

  export ARCH='x86_64'
  export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX.sdk'
  export CLANG_IVERSION='-mmacos-version-min=10.15'

  set_common
}