#!/bin/zsh -f
common() {
  CONFIG_FLAGS='--disable-graphics'
  export CC="$(xcode-select -p)/usr/bin/gcc --target=$TARGET"
  export CFLAGS=-I{ROOT}/{PKG_NAME}/$PLATFORM_OS/$TARGET/
  export CXX="$(xcode-select -p)/usr/bin/g++ --target=$TARGET"
  CXXFLAGS_ARR=(
    $PLATFORM_VERSION
    "-arch $ARCH"
    "-isysroot $SDKROOT"
    "-I{ROOT}/{PKG_NAME}/$PLATFORM_OS/$TARGET/"
    '-no-cpp-precomp'
    '-O2'
    '-pipe'
  )
  export CXXFLAGS="$CXXFLAGS_ARR"

  export CXX_FOR_BUILD="$(xcode-select -p)/usr/bin/g++ --target=$TARGET"
  LDFLAGS_ARR=(
    "-L{ROOT}/$PLATFORM_OS/lib"
    "-L{ROOT}/leptonica-1.78.0/$PLATFORM_OS/$TARGET/src/.libs"
  )
  export LDFLAGS="$LDFLAGS_ARR"

  export LIBLEPT_HEADERSDIR={ROOT}/{PKG_NAME}/$PLATFORM_OS/$TARGET/
  export LIBS=''-lz -lpng -ljpeg -ltiff''
  export PKG_CONFIG_PATH={ROOT}/leptonica-1.78.0/$PLATFORM_OS/$TARGET/

  common_all
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
