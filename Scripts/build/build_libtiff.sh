#!/bin/zsh -f

# LIBTIFF -- https://gitlab.com/libtiff/libtiff

scriptname=$0:A
parentdir=${scriptname%/build_libtiff.sh}
if ! source $parentdir/project_environment.sh -u ; then
  echo "build_libtiff.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if [[ -n $1 ]] && [[ $1 == 'clean' ]]; then
  echo 'Deleting...'
  find $ROOT -name '*tiff*' -prune -print -exec rm -rf {} \;
  exit 0
fi

local name='tiff-4.1.0'

print "\n======== $name ========"

# --  Download / Extract  -----------------------------------------------------

targz=$name.tar.gz
url="http://download.osgeo.org/libtiff/$targz"

zsh $parentdir/_download.sh $name $url $targz
zsh $parentdir/_extract.sh $name $targz

# --  Config / Make / Install  ------------------------------------------------

# ios_arm64
export ARCH='arm64'
export TARGET='arm-apple-darwin64'
export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=11.0'

zsh $parentdir/config-make-install_libtiff.sh $name 'ios_arm64'

# ios_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk'
export PLATFORM_MIN_VERSION='-mios-simulator-version-min=11.0'

zsh $parentdir/config-make-install_libtiff.sh $name 'ios_x86_64'

# macos_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=10.13'

zsh $parentdir/config-make-install_libtiff.sh $name 'macos_x86_64'

# --  Lipo  -------------------------------------------------------------------
xc mkdir -p $ROOT/lib

print -n 'lipo: ios... '
xl $name '5_ios_lipo' \
  xcrun lipo $ROOT/ios_arm64/lib/libtiff.a $ROOT/ios_x86_64/lib/libtiff.a \
  -create -output $ROOT/lib/libtiff.a
print 'done.'

print -n 'lipo: macos... '
xl $name '5_macos_lipo' \
  xcrun lipo $ROOT/macos_x86_64/lib/libtiff.a \
  -create -output $ROOT/lib/libtiff-macos.a
print 'done.'
