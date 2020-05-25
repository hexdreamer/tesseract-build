#!/bin/zsh -f

# LEPTONICA -- https://github.com/DanBloomberg/leptonica

export NAME='leptonica-1.79.0'
export TARGZ="$NAME.tar.gz"
export URL="https://github.com/DanBloomberg/leptonica/releases/download/1.79.0/$TARGZ"
export VER_PATTERN='lept >= 1.79.0'
export LIBNAME='liblept'
export IOS_TARGETS=('ios_arm64' 'ios_x86_64')
export MACOS_TARGETS=('macos_x86_64')
export TARGETS=($IOS_TARGETS $MACOS_TARGETS)

common() {
  source "${SCRIPTSDIR}/configs/common.sh"
  common_all

  CONFIG_FLAGS=(
    $CONFIG_FLAGS
    '--disable-programs'
    '--with-jpeg'
    '--with-libpng'
    '--with-libtiff'
    '--with-zlib'
    '--without-giflib'
    '--without-libwebp'
  )

  export CC="$(xcode-select -p)/usr/bin/gcc --target=$TARGET"
  export CXX="$(xcode-select -p)/usr/bin/g++ --target=$TARGET"
  export CXX_FOR_BUILD="$(xcode-select -p)/usr/bin/g++ --target=$TARGET"

    CFLAGS_ARR=(
    $CFLAGS
    -I${ROOT}/${PLATFORM_OS}_${ARCH}/include
  )
  export CFLAGS="$CFLAGS_ARR"

  CXXFLAGS_ARR=(
    $CXXFLAGS
    $PLATFORM_VERSION
    "-arch $ARCH"
    "-isysroot $SDKROOT"
    "-I${ROOT}/${PLATFORM_OS}_${ARCH}/include"
    '-no-cpp-precomp'
    '-O2'
    '-pipe'
  )
  export CXXFLAGS="$CXXFLAGS_ARR"

  export LDFLAGS_ARR=(
    $LDFLAGS
    -L$ROOT/${PLATFORM_OS}_${ARCH}/lib
  )
  export LDFLAGS="$LDFLAGS_ARR"

  export LIBS='-lz -lpng -ljpeg -ltiff'

  # Commenting out because previous experience w/PKG_CONFIG_PATH showed it was unnecessary
  # export PKG_CONFIG_PATH={ROOT}/libpng-1.6.36/$TARGET/:{ROOT}/jpeg-9c/$TARGET/:{ROOT}/tiff-4.0.10/$TARGET/

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
