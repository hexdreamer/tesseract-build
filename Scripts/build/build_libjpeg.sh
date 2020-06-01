#!/bin/zsh -f

# LIBJPEG -- http://ijg.org/

scriptname=$0:A
parentdir=${scriptname%/build_libjpeg.sh}
if ! source $parentdir/project_environment.sh -u ; then
  echo "build_libjpeg.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

local name='jpegsrc.v9d'

print "\n======== $name ========"

# --  Download / Extract  -----------------------------------------------------

targz=$name.tar.gz
url="http://www.ijg.org/files/$targz"
dirname='jpeg-9d'

zsh $parentdir/_download.sh $name $url $targz
zsh $parentdir/_extract.sh $name $targz $dirname

# --  Config / Make / Install  ------------------------------------------------

# ios_arm64
export ARCH='arm64'
export TARGET='arm-apple-darwin64'
export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=11.0'

zsh $parentdir/config-make-install_libjpeg.sh $name 'ios_arm64' $dirname

# ios_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk'
export PLATFORM_MIN_VERSION='-mios-simulator-version-min=11.0'

zsh $parentdir/config-make-install_libjpeg.sh $name 'ios_x86_64' $dirname

# macos_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=10.13'

zsh $parentdir/config-make-install_libjpeg.sh $name 'macos_x86_64' $dirname

# --  Lipo  -------------------------------------------------------------------
xc mkdir -p $ROOT/lib

print -n 'lipo: ios... '
xl $name '5_ios_lipo' \
  xcrun lipo $ROOT/ios_arm64/lib/libjpeg.a $ROOT/ios_x86_64/lib/libjpeg.a \
    -create -output $ROOT/lib/libjpeg.a
print 'done.'

print -n 'lipo: macos... '
xl $name '5_macos_lipo' \
  xcrun lipo $ROOT/macos_x86_64/lib/libjpeg.a \
    -create -output $ROOT/lib/libjpeg-macos.a
print 'done.'