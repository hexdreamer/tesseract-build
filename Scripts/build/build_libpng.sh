#!/bin/zsh -f

# LIBPNG -- http://www.libpng.org/pub/png/libpng.html

scriptpath=$0:A
parentdir=${scriptpath%/*}
scriptname=${scriptpath##*/}

if ! source $parentdir/project_environment.sh; then
  echo "build_libpng.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if [[ -n $1 ]] && [[ $1 == 'clean' ]]; then
  deleted=$(find $ROOT -name '*png*' -prune -print -exec rm -rf {} \;)
  if [[ -n $deleted ]]; then
    echo "$scriptname: deleted:"
    echo $deleted
  else
    echo "$scriptname: clean"
  fi
  exit 0
fi

name='libpng-1.6.37'

print "\n======== $name ========"

# --  Download / Extract  -----------------------------------------------------

targz=$name.tar.gz
url="https://downloads.sourceforge.net/project/libpng/libpng16/1.6.37/$targz"

download $name $url $targz
extract $name $targz

# --  Config / Make / Install  ------------------------------------------------

# ios_arm64
export ARCH='arm64'
export TARGET='arm64-apple-ios14.3'
export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=14.3'

zsh $parentdir/config-make-install_libpng.sh $name 'ios_arm64' || exit 1

# ios_arm64_sim
export ARCH='arm64'
export TARGET='arm64-apple-ios14.3-simulator'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=14.3'

zsh $parentdir/config-make-install_libpng.sh $name 'ios_arm64_sim' || exit 1

# ios_x86_64_sim
export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk'
export PLATFORM_MIN_VERSION='-mios-simulator-version-min=14.3'

zsh $parentdir/config-make-install_libpng.sh $name 'ios_x86_64_sim' || exit 1

# macos_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-macos10.13'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=10.13'

zsh $parentdir/config-make-install_libpng.sh $name 'macos_x86_64' || exit 1

# macos_arm64
export ARCH='arm64'
export TARGET='arm64-apple-macos11.0'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=11.0'

zsh $parentdir/config-make-install_libpng.sh $name 'macos_arm64' || exit 1

# --  Lipo  -------------------------------------------------------------------

xc mkdir -p $ROOT/lib

print -n 'lipo: ios... '
xl $name '5_ios_lipo' \
  xcrun lipo $ROOT/ios_arm64/lib/libpng16.a \
  -create -output $ROOT/lib/libpng16-ios.a
print 'done.'

print -n 'lipo: sim... '
xl $name '5_sim_lipo' \
  xcrun lipo $ROOT/ios_arm64_sim/lib/libpng16.a $ROOT/ios_x86_64_sim/lib/libpng16.a \
  -create -output $ROOT/lib/libpng16-sim.a
print 'done.'

print -n 'lipo: macos... '
xl $name '5_macos_lipo' \
  xcrun lipo $ROOT/macos_x86_64/lib/libpng16.a $ROOT/macos_arm64/lib/libpng16.a \
  -create -output $ROOT/lib/libpng16-macos.a
print 'done.'

xc cd $ROOT/lib
xc ln -fs libpng16.a libpng.a
xc ln -fs libpng16-macos.a libpng-macos.a

# --  Copy headers  -----------------------------------------------------------

xc mkdir -p $ROOT/include/libpng16
xc cp $ROOT/ios_arm64/include/libpng16/* $ROOT/include/libpng16
xc cp $ROOT/ios_arm64/include/png*.h     $ROOT/include
