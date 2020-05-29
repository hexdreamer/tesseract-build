#! /bin/zsh -f

# LIBPNG -- http://www.libpng.org/pub/png/libpng.html

scriptname=$0:A
parentdir=${scriptname%/build_libpng.sh}
if ! source $parentdir/project_environment.sh; then
  echo "build_libpng.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if ! source $SCRIPTSDIR/utility.sh; then
  echo "build_libpng.sh: error sourcing $SCRIPTSDIR/project_environment.sh"
  exit 1
fi

local name='libpng-1.6.37'
# local ver_pattern='libpng >= 1.6.37'

print "\n======== $name ========"

# Being respectful of hosts and their bandwidth
targz=$name.tar.gz
if [ -e $DOWNLOADS/$targz ]; then
  echo "Skipped download, using cached $targz in Downloads."
else
  print -n 'Downloading...'
  url="https://sourceforge.net/projects/libpng/files/libpng16/1.6.37/$targz/download"
  exec_and_log $name '0_curl' curl -L -f $url --output $DOWNLOADS/$targz
  print ' done.'
fi

# Being respectful of any hacking/work done to get a package to build
if [ -d $SOURCES/$name ]; then
  echo "Skipped extract of TGZ, using cached $name in Sources."
else
  print -n 'Extracting...'
  exec_and_log $name '1_untar' tar -zxf $DOWNLOADS/$targz --directory $SOURCES
  print ' done.'
fi

# --  ios_arm64  --------------------------------------------------------------
arch='arm64'
target='arm-apple-darwin64'
platform='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk'
platform_min_version='-miphoneos-version-min=11.0'

cflags_arr=(
  $platform_min_version
  "-arch $arch"
  "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$platform"
  \
  '-fembed-bitcode'
  '-no-cpp-precomp'
  '-O2'
  '-pipe'
)

config_flags=(
  CC="$(xcode-select -p)/usr/bin/gcc --target=$target"
  CXX="$(xcode-select -p)/usr/bin/g++ --target=$target"
  \
  CFLAGS="$cflags_arr"
  CPPFLAGS="$cflags_arr"
  CXXFLAGS="$cflags_arr -Wno-deprecated-register"
  LDFLAGS=-L/Applications/Xcode.app/Contents/Developer/Platforms/$platform/usr/lib/
  PKG_CONFIG_PATH=$ROOT/ios_arm64/lib/pkgconfig
  \
  "--host=$target"
  '--enable-shared=no'
)

_exec mkdir -p $SOURCES/$name/ios_arm64
_exec cd $SOURCES/$name/ios_arm64

print -n 'ios_arm64: '

print -n 'configuring... '
configure=(
  ../configure
  $config_flags
  "--prefix=$ROOT/ios_arm64"
)
exec_and_log $name '2_config_ios_arm64' $configure || exit 1
print -n 'done, '

print -n 'making... '
exec_and_log $name '3_make_ios_arm64' make || exit 1
print -n 'done, '

print -n 'installing... '
exec_and_log $name '4_install_ios_arm64' make install || exit 1
print 'done.'

# --  ios_x86_64  --------------------------------------------------------------
arch='x86_64'
target='x86_64-apple-darwin'
platform='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk'
platform_min_version='-mios-simulator-version-min=11.0'

cflags_arr=(
  $platform_min_version
  "-arch $arch"
  "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$platform"
  \
  '-fembed-bitcode'
  '-no-cpp-precomp'
  '-O2'
  '-pipe'
)

config_flags=(
  CC="$(xcode-select -p)/usr/bin/gcc --target=$target"
  CXX="$(xcode-select -p)/usr/bin/g++ --target=$target"
  \
  CFLAGS="$cflags_arr"
  CPPFLAGS="$cflags_arr"
  CXXFLAGS="$cflags_arr -Wno-deprecated-register"
  LDFLAGS=-L/Applications/Xcode.app/Contents/Developer/Platforms/$platform/usr/lib/
  PKG_CONFIG_PATH=$ROOT/ios_x86_64/lib/pkgconfig
  \
  "--host=$target"
  '--enable-shared=no'
)

_exec mkdir -p $SOURCES/$name/ios_x86_64
_exec cd $SOURCES/$name/ios_x86_64

print -n 'ios_x86_64: '

print -n 'configuring... '
configure=(
  ../configure
  $config_flags
  "--prefix=$ROOT/ios_x86_64"
)
exec_and_log $name '2_config_ios_x86_64' $configure || exit 1
print -n 'done, '

print -n 'making... '
exec_and_log $name '3_make_ios_x86_64' make || exit 1
print -n 'done, '

print -n 'installing... '
exec_and_log $name '4_install_ios_x86_64' make install || exit 1
print 'done.'

# --  macos_x86_64  --------------------------------------------------------------
arch='x86_64'
target='x86_64-apple-darwin'
platform='MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk'
platform_min_version='-mmacosx-version-min=10.13'

cflags_arr=(
  $platform_min_version
  "-arch $arch"
  "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$platform"
  \
  '-fembed-bitcode'
  '-no-cpp-precomp'
  '-O2'
  '-pipe'
)

config_flags=(
  CC="$(xcode-select -p)/usr/bin/gcc --target=$target"
  CXX="$(xcode-select -p)/usr/bin/g++ --target=$target"
  \
  CFLAGS="$cflags_arr"
  CPPFLAGS="$cflags_arr"
  CXXFLAGS="$cflags_arr -Wno-deprecated-register"
  LDFLAGS=-L/Applications/Xcode.app/Contents/Developer/Platforms/$platform/usr/lib/
  PKG_CONFIG_PATH=$ROOT/macos_x86_64/lib/pkgconfig
  \
  "--host=$target"
  '--enable-shared=no'
)

_exec mkdir -p $SOURCES/$name/macos_x86_64
_exec cd $SOURCES/$name/macos_x86_64

print -n 'macos_x86_64: '

print -n 'configuring... '
configure=(
  ../configure
  $config_flags
  "--prefix=$ROOT/macos_x86_64"
)
exec_and_log $name '2_config_macos_x86_64' $configure || exit 1
print -n 'done, '

print -n 'making... '
exec_and_log $name '3_make_macos_x86_64' make || exit 1
print -n 'done, '

print -n 'installing... '
exec_and_log $name '4_install_macos_x86_64' make install || exit 1
print 'done.'

# --  Lipo  -------------------------------------------------------------------
_exec mkdir -p $ROOT/lib

print -n 'lipo: ios... '
exec_and_log $name '6_ios_lipo' \
  xcrun lipo $ROOT/ios_arm64/lib/libpng16.a $ROOT/ios_x86_64/lib/libpng16.a \
  -create -output $ROOT/lib/libpng16.a

_exec cd $ROOT/lib
_exec ln -fs libpng16.a libpng.a

print 'done.'

print -n 'lipo: macos... '
exec_and_log $name '7_macos_lipo' \
  xcrun lipo $ROOT/macos_x86_64/lib/libpng16.a \
  -create -output $ROOT/lib/libpng16-macos.a

_exec cd $ROOT/lib
_exec ln -fs libpng16-macos.a libpng-macos.a
print 'done.'
