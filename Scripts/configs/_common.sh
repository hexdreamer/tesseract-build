#!/bin/zsh -f

ios_arm() {
  export TARGET='arm-apple-darwin64'

  export ARCH='arm64'
  export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk'
  export CLANG_IVERSION='-miphoneos-version-min=11.0'
}

ios_x86() {
  export TARGET='x86_64-apple-darwin'

  export ARCH='x86_64'
  export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk'
  export CLANG_IVERSION='-mios-simulator-version-min=11.0'
}

mac_x86() {
  export TARGET='x86_64-apple-darwin'

  export ARCH='x86_64'
  export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX.sdk'
  export CLANG_IVERSION='-mmacos-version-min=10.15'
}