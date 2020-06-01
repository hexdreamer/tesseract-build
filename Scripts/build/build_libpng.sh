#! /bin/zsh -f

# LIBPNG -- http://www.libpng.org/pub/png/libpng.html

scriptname=$0:A
parentdir=${scriptname%/build_libpng.sh}
if ! source $parentdir/project_environment.sh; then
  echo "build_libpng.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if [[ -n $1 ]] && [[ $1 == 'clean' ]]; then
  echo 'Deleting...'
  find $ROOT -name '*png*' -prune -print -exec rm -rf {} \;
  exit 0
fi

name='libpng-1.6.37'

print "\n======== $name ========"

# --  Download / Extract  -----------------------------------------------------

targz=$name.tar.gz
url="https://sourceforge.net/projects/libpng/files/libpng16/1.6.37/$targz/download"

download $name $url $targz
extract $name $targz

# --  Config / Make / Install  ------------------------------------------------

export ARCH='arm64'
export TARGET='arm-apple-darwin64'
export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=11.0'

zsh $parentdir/config-make-install_libpng.sh $name 'ios_arm64'

export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk'
export PLATFORM_MIN_VERSION='-mios-simulator-version-min=11.0'

zsh $parentdir/config-make-install_libpng.sh $name 'ios_x86_64'

export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=10.13'

zsh $parentdir/config-make-install_libpng.sh $name 'macos_x86_64'

# --  Lipo  -------------------------------------------------------------------

xc mkdir -p $ROOT/lib

print -n 'lipo: ios... '
xl $name '5_ios_lipo' \
  xcrun lipo $ROOT/ios_arm64/lib/libpng16.a $ROOT/ios_x86_64/lib/libpng16.a \
  -create -output $ROOT/lib/libpng16.a

xc cd $ROOT/lib
xc ln -fs libpng16.a libpng.a

print 'done.'

print -n 'lipo: macos... '
xl $name '5_macos_lipo' \
  xcrun lipo $ROOT/macos_x86_64/lib/libpng16.a \
  -create -output $ROOT/lib/libpng16-macos.a

xc cd $ROOT/lib
xc ln -fs libpng16-macos.a libpng-macos.a
print 'done.'
