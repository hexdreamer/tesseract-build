#!/bin/zsh -f

# TESSERACT OCR -- https://github.com/tesseract-ocr/tesseract

export NAME='tesseract-4.1.1'
export TARGZ="$NAME.tar.gz"
export URL='https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz'
export VER_PATTERN='tesseract >= 4.1.1'
export LIBNAME='libtesseract'
export IOS_TARGETS=('ios_arm64' 'ios_x86_64')
export MACOS_TARGETS=('macos_x86_64')
export TARGETS=($IOS_TARGETS $MACOS_TARGETS)

common() {
  source "${SCRIPTSDIR}/configs/common.sh"
  common_all

  CONFIG_FLAGS=(
    $CONFIG_FLAGS
    '--disable-graphics'
  )

  export CC="$(xcode-select -p)/usr/bin/gcc --target=$TARGET"
  export CXX="$(xcode-select -p)/usr/bin/g++ --target=$TARGET"
  
  CFLAGS_ARR=(
    $CFLAGS
    "-I${ROOT}/${PLATFORM_OS}_${ARCH}"
  )
  export CFLAGS="$CFLAGS_ARR"

  CXXFLAGS_ARR=(
    $CXXFLAGS
    $PLATFORM_VERSION
    "-arch $ARCH"
    "-isysroot $SDKROOT"
    "-I${ROOT}/${PLATFORM_OS}_${ARCH}"
    '-no-cpp-precomp'
    '-O2'
    '-pipe'
  )
  export CXXFLAGS="$CXXFLAGS_ARR"

  export CXX_FOR_BUILD="$(xcode-select -p)/usr/bin/g++ --target=$TARGET"

  LDFLAGS_ARR=(
      $LDFLAGS
    -L$ROOT/${PLATFORM_OS}_${ARCH}/lib
    # "-L{ROOT}/leptonica-1.78.0/$PLATFORM_OS/$TARGET/src/.libs"
  )
  export LDFLAGS="$LDFLAGS_ARR"

  export LIBLEPT_HEADERSDIR=${ROOT}/${PLATFORM_OS}_${ARCH}/include
  export LIBS='-lz -lpng -ljpeg -ltiff'

  export CONFIG_CMD='../configure'
  export PRECONFIG='./autogen.sh'
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
