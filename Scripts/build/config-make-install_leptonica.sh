#!/bin/zsh -f

scriptpath=$0:A
parentdir=${scriptpath%/*}

if ! source $parentdir/project_environment.sh; then
  echo Error sourcing $parentdir/project_environment.sh
  exit 1
fi

# ARCH='arm64'
# TARGET='arm-apple-darwin64'
# PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk'
# PLATFORM_MIN_VERSION='-miphoneos-version-min=11.0'

name=$1    # leptonica-1.80.0
os_arch=$2 # ios_arm64

print -n "$os_arch: "

# Verify liblept.a is installed; requires pkglib is installed
pkg_lib=$ROOT/$os_arch/lib/liblept.a
if {
  [ -f $pkg_lib ] &&
    info=$(lipo -info $pkg_lib) &&
    [[ $info =~ 'Non-fat file' ]] &&
    [[ $info =~ $ARCH ]]
}; then
  print "skipped config/make/install, found valid single-$ARCH-arch $pkg_lib"
  exit 0
fi

# Verify sysroot platform exists
if [ ! -d /Applications/Xcode.app/Contents/Developer/Platforms/$PLATFORM ]; then
  print "ERROR $PLATFORM does not exist; has the SDK been updated?"
fi

cflags=(
  "-arch $ARCH"
  "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$PLATFORM"
  "-I$ROOT/$os_arch/include"
  $PLATFORM_MIN_VERSION
  "--target=$TARGET"

  '-fembed-bitcode'
  '-no-cpp-precomp'
  '-O2'
  '-pipe'
)

config_flags=(
  CC="$(xcode-select -p)/usr/bin/gcc"
  CXX="$(xcode-select -p)/usr/bin/g++"
  CXX_FOR_BUILD="$(xcode-select -p)/usr/bin/g++"
  CFLAGS="$cflags"
  CPPFLAGS="$cflags"
  CXXFLAGS="$cflags -Wno-deprecated-register"
  LDFLAGS="-L$ROOT/$os_arch/lib -L/Applications/Xcode.app/Contents/Developer/Platforms/$PLATFORM/usr/lib/"
  LIBS='-lz -lpng -ljpeg -ltiff'
  PKG_CONFIG_PATH="$ROOT/$os_arch/lib/pkgconfig"

  '--disable-programs'
  '--enable-shared=no'
  "--host=$TARGET"
  "--prefix=$ROOT/$os_arch"
  '--with-jpeg'
  '--with-libpng'
  '--with-libtiff'
  '--with-zlib'
  '--without-giflib'
  '--without-libwebp'
)

xc mkdir -p $SOURCES/$name/$os_arch || exit 1
xc cd $SOURCES/$name/$os_arch || exit 1

print -n 'configuring... '
xl $name "3_config_$os_arch" ../configure $config_flags || exit 1
print -n 'done, '

print -n 'making... '
xl $name "4_clean_$os_arch" make clean || exit 1
xl $name "4_make_$os_arch" make || exit 1
print -n 'done, '

print -n 'installing... '
xl $name "5_install_$os_arch" make install || exit 1
print 'done.'
