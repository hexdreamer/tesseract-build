#!/bin/zsh -f

# TESSERACT OCR -- https://github.com/tesseract-ocr/tesseract

scriptpath=$0:A
parentdir=${scriptpath%/*}
scriptname=${scriptpath##*/}

if ! source $parentdir/project_environment.sh; then
  echo "build_tesseract.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if [[ -n $1 ]] && [[ $1 == 'clean' ]]; then
  deleted=$(find $ROOT -name '*tess*' -prune -print -exec rm -rf {} \;)
  if [[ -n $deleted ]]; then
    echo "$scriptname: deleting..."
    echo $deleted
  else
    echo "$scriptname: clean"
  fi
  exit 0
fi

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

# ios_arm64
export ARCH='arm64'
export TARGET='arm-apple-darwin64'
export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=11.0'

zsh $parentdir/config-make-install_tesseract.sh $name 'ios_arm64' || exit 1

# ios_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk'
export PLATFORM_MIN_VERSION='-mios-simulator-version-min=11.0'

zsh $parentdir/config-make-install_tesseract.sh $name 'ios_x86_64' || exit 1

# macos_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=10.13'

zsh $parentdir/config-make-install_tesseract.sh $name 'macos_x86_64' || exit 1

# --  Lipo  -------------------------------------------------------------------

xc mkdir -p $ROOT/lib

print -n 'ios: lipo... '
xl $name '6_lipo_ios' \
  xcrun lipo $ROOT/ios_arm64/lib/libtesseract.a $ROOT/ios_x86_64/lib/libtesseract.a \
  -create -output $ROOT/lib/libtesseract.a ||
  exit 1
print 'done.'

print -n 'macos: lipo... '
xl $name '6_lipo_macos' \
  xcrun lipo $ROOT/macos_x86_64/lib/libtesseract.a \
  -create -output $ROOT/lib/libtesseract-macos.a ||
  exit 1
print 'done.'
