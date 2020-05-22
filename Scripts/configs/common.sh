#!/bin/zsh -f
common_all() {
  CONFIG_FLAGS=(
    CC="$(xcode-select -p)/usr/bin/gcc --target=$TARGET"
    CXX="$(xcode-select -p)/usr/bin/g++ --target=$TARGET"
    '--enable-shared=no'
    "--host=$TARGET"
    "--prefix=$(pwd)"
  )

  CFLAGS_ARR=(
    $PLATFORM_VERSION
    "-arch $ARCH"
    '-fembed-bitcode'
    "-isysroot $SDKROOT"
    '-no-cpp-precomp'
    '-O2'
    '-pipe'
  )
  export CFLAGS="$CFLAGS_ARR"

  export CPPFLAGS=$CFLAGS
  export CXXFLAGS='-Wno-deprecated-register'
  export LDFLAGS=-L$SDKROOT/usr/lib/
  export SDKROOT="{XCODE_DEV}/Platforms/$PLATFORM"
}
