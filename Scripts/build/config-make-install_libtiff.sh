#!/bin/zsh

scriptpath=$0:A
parentdir=${scriptpath%/*}

if ! source $parentdir/project_environment.sh; then
  echo "config-make-install_libtiff.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

# ARCH='arm64'
# TARGET='arm-apple-darwin64'
# PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk'
# PLATFORM_MIN_VERSION='-miphoneos-version-min=11.0'

name=$1    # tiff-4.1.0
os_arch=$2 # ios_arm64

print -n "$os_arch: "

# Verify libtiff.a is installed; requires pkglib is installed
pkg_lib=$ROOT/$os_arch/lib/libtiff.a
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
  CFLAGS="$cflags"
  CPPFLAGS="$cflags"
  CXXFLAGS="$cflags -Wno-deprecated-register"
  LDFLAGS="-L/Applications/Xcode.app/Contents/Developer/Platforms/$PLATFORM/usr/lib/"
  PKG_CONFIG_PATH="$ROOT/$os_arch/lib/pkgconfig"

  '--enable-fast-install'
  '--enable-shared=no'
  "--host=$TARGET"
  "--prefix=$ROOT/$os_arch"
  "--with-jpeg-include-dir=$ROOT/$os_arch/include"
  "--with-jpeg-lib-dir=$ROOT/$os_arch/lib"
  '--without-x'
)

xc mkdir -p $SOURCES/$name/$os_arch
xc cd $SOURCES/$name/$os_arch

print -n 'configuring... '
xl $name "2_config_$os_arch" ../configure $config_flags || exit 1
print -n 'done, '

print -n 'making... '
xl $name "3_clean_$os_arch" make clean || exit 1
xl $name "3_make_$os_arch" make || exit 1
print -n 'done, '

print -n 'installing... '
xl $name "4_install_$os_arch" make install || exit 1
print 'done.'
