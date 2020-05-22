#!/bin/zsh -f
common_all() {
  export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/$PLATFORM"
  export LDFLAGS=-L$SDKROOT/usr/lib/

  CONFIG_FLAGS=(
    CC="$(xcode-select -p)/usr/bin/gcc --target=$TARGET"
    CXX="$(xcode-select -p)/usr/bin/g++ --target=$TARGET"
    '--enable-shared=no'
    "--host=$TARGET"
  )

  CFLAGS_ARR=(
    "-arch $ARCH"
    '-fembed-bitcode'
    "-isysroot $SDKROOT"
    $PLATFORM_VERSION
    '-no-cpp-precomp'
    '-O2'
    '-pipe'
  )
  export CFLAGS="$CFLAGS_ARR"

  export CPPFLAGS=$CFLAGS
  
  export CXXFLAGS='-Wno-deprecated-register'
}
