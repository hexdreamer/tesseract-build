#!/bin/zsh -f

# TESSERACT OCR -- https://github.com/tesseract-ocr/tesseract

scriptpath=$0:A
parentdir=${scriptpath%/*}
scriptname=${scriptpath##*/}

source $parentdir/project_environment.sh || {
  echo "build_tesseract.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
}

if [[ -n $1 ]] && [[ $1 == 'clean' ]]; then
  deleted=$(find $ROOT -name '*tess*' -prune -print -exec rm -rf {} \;)
  if [[ -n $deleted ]]; then
    echo "$scriptname: deleted:"
    echo $deleted
  else
    echo "$scriptname: clean"
  fi
  exit 0
fi

# Check out this page for version updates: https://tesseract-ocr.github.io/tessdoc/
name='tesseract-4.1.1'

print "\n======== $name ========"

# --  Download / Extract  -----------------------------------------------------

targz='4.1.1.tar.gz'
url="https://github.com/tesseract-ocr/tesseract/archive/$targz"

download $name $url $targz || exit 1
extract $name $targz || exit 1

# --  Preconfigure  -----------------------------------------------------------

print -n 'Preconfiguring... '
xc cd $SOURCES/$name || exit 1
xl $name '2_preconfig' ./autogen.sh || exit 1
print 'done.'

# --  Config / Make / Install  ------------------------------------------------

# Special override till GNU config catches up with new Apple targets
print -- "--**!!**-- Overriding \$SOURCES/$name/config/config.sub"
echo "echo 'arm-apple-darwin64'" > $SOURCES/$name/config/config.sub

# ios_arm64
export ARCH='arm64'
export TARGET='arm64-apple-ios14.3'
export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=14.3'

zsh $parentdir/config-make-install_tesseract.sh $name 'ios_arm64' || exit 1

# ios_arm64_sim
export ARCH='arm64'
export TARGET='arm64-apple-ios14.3-simulator'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=14.3'

zsh $parentdir/config-make-install_tesseract.sh $name 'ios_arm64_sim' || exit 1

# ios_x86_64_sim
export ARCH='x86_64'
export TARGET='x86_64-apple-ios14.3-simulator'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk'
export PLATFORM_MIN_VERSION='-mios-simulator-version-min=14.3'

zsh $parentdir/config-make-install_tesseract.sh $name 'ios_x86_64_sim' || exit 1

# macos_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-macos10.13'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=10.13'

zsh $parentdir/config-make-install_tesseract.sh $name 'macos_x86_64' || exit 1

# macos_arm64
export ARCH='arm64'
export TARGET='arm64-apple-macos11.0'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=11.0'

zsh $parentdir/config-make-install_tesseract.sh $name 'macos_arm64' || exit 1

# --  Lipo libs  --------------------------------------------------------------

xc mkdir -p $ROOT/lib

print -n 'lipo: ios... '
xl $name '6_ios_lipo' \
  xcrun lipo $ROOT/ios_arm64/lib/libtesseract.a \
  -create -output $ROOT/lib/libtesseract-ios.a ||
  exit 1
print 'done.'

print -n 'lipo: sim... '
xl $name '6_sim_lipo' \
  xcrun lipo $ROOT/ios_arm64_sim/lib/libtesseract.a $ROOT/ios_x86_64_sim/lib/libtesseract.a \
  -create -output $ROOT/lib/libtesseract-sim.a ||
  exit 1
print 'done.'

print -n 'lipo: macos... '
xl $name '6_macos_lipo' \
  xcrun lipo $ROOT/macos_x86_64/lib/libtesseract.a $ROOT/macos_arm64/lib/libtesseract.a \
  -create -output $ROOT/lib/libtesseract-macos.a ||
  exit 1
print 'done.'

# --  Copy headers  -----------------------------------------------------------

xc ditto $ROOT/ios_arm64/include/tesseract $ROOT/include/tesseract

# --  Copy training/initialization data  --------------------------------------

xc ditto $ROOT/ios_arm64/share/tessdata $ROOT/share/tessdata

# --  Copy tesseract command-line program  ------------------------------------

print -n 'tesseract command-line: copying... '
cp $ROOT/macos_arm64/bin/tesseract $ROOT/bin/tesseract-arm64
cp $ROOT/macos_x86_64/bin/tesseract $ROOT/bin/tesseract-x86_64

print -n 'sym-linking to arm64 binary... '
cd $ROOT/bin || exit 1
ln -fs tesseract-arm64 tesseract

print 'done.'