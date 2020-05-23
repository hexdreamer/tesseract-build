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

unset_target_configs() {
  unset ARCH
  unset CFLAGS
  unset CFLAGS_ARR
  unset CONFIG_CMD
  unset CONFIG_FLAGS
  unset CPPFLAGS
  unset CXXFLAGS
  unset CXXFLAGS_ARR
  unset LDFLAGS
  unset PLATFORM
  unset PLATFORM_OS
  unset PLATFORM_VERSION
  unset SDKROOT
  unset TARGET
}

unset_pkg_properties() {
  unset NAME
  unset TARGETS
  unset TARGZ
  unset URL
  unset VER_PATTERN
}

unset_all() {
  unset_pkg_properties
  unset_target_configs
}
