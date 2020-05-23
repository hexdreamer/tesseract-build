#!/bin/zsh -f

# LIBPNG -- http://www.libpng.org/pub/png/libpng.html

export NAME='libpng-1.6.37'
export TARGZ="$NAME.tar.gz"
export URL="https://sourceforge.net/projects/libpng/files/libpng16/1.6.37/$TARGZ/download"
# export VER_COMMAND='libpng-config --version'
export VER_PATTERN='libpng >= 1.6.37'
export TARGETS=('ios_arm64' 'ios_x86_64' 'macos_x86_64')

common() {
  source "${SCRIPTSDIR}/configs/common.sh"
  common_all

  CXXFLAGS_ARR=(
    $CXXFLAGS
    $CFLAGS
  )
  export CXXFLAGS="$CXXFLAGS_ARR"

  export CONFIG_CMD='../configure'
}

ios_arm64() {
  export ARCH='arm64'
  export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk'
  export PLATFORM_OS='ios'
  export PLATFORM_VERSION='-miphoneos-version-min=11.0'
  export TARGET='arm-apple-darwin64'

  common
}

ios_x86_64() {
  export ARCH='x86_64'
  export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk'
  export PLATFORM_OS='ios'
  export PLATFORM_VERSION='-mios-simulator-version-min=11.0'
  export TARGET='x86_64-apple-darwin'

  common
}

macos_x86_64() {
  export ARCH='x86_64'
  export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk'
  export PLATFORM_OS='macos'
  export PLATFORM_VERSION='-mmacosx-version-min=10.13'
  export TARGET='x86_64-apple-darwin'

  common
}
