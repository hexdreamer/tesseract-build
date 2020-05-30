#!/bin/zsh -f

# LIBTIFF -- https://gitlab.com/libtiff/libtiff

scriptname=$0:A
parentdir=${scriptname%/build_libtiff.sh}
if ! source $parentdir/project_environment.sh; then
  echo "build_libtiff.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if ! source $SCRIPTSDIR/utility.sh; then
  echo "build_libtiff.sh: error sourcing $SCRIPTSDIR/utility.sh"
  exit 1
fi

local name='tiff-4.1.0'

print "\n======== $name ========"

# Being respectful of hosts and their bandwidth
targz=$name.tar.gz
if [ -e $DOWNLOADS/$targz ]; then
  echo "Skipped download, using cached $targz in Downloads."
else
  print -n 'Downloading...'
  url="export URL="http://download.osgeo.org/libtiff/$targz""
  xl $name '0_curl' curl -L -f $url --output $DOWNLOADS/$targz
  print ' done.'
fi

# Being respectful of any hacking/work done to get a package to build
if [ -d $SOURCES/$name ]; then
  echo "Skipped extract of TGZ, using cached $name in Sources."
else
  print -n 'Extracting...'
  xl $name '1_untar' tar -zxf $DOWNLOADS/$targz --directory $SOURCES
  print ' done.'
fi

# --  ios_arm64  --------------------------------------------------------------
print -n 'ios_arm64: '

export PKG_CONFIG_PATH=$ROOT/ios_arm64/lib/pkgconfig
if {
  pkg-config --exists --print-errors 'libtiff-4 >= 4.1.0' &&
    [ -f $ROOT/ios_arm64/lib/libtiff.a ]
}; then

  print 'skipped config/make/install, found ROOT/ios_arm64/lib/libtiff.a'

else

  arch='arm64'
  target='arm-apple-darwin64'
  platform='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk'
  platform_min_version='-miphoneos-version-min=11.0'

  cflags=(
    "-arch $arch"
    "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$platform"
    $platform_min_version
    "--target=$target"
    \
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
    LDFLAGS="-L/Applications/Xcode.app/Contents/Developer/Platforms/$platform/usr/lib/"
    PKG_CONFIG_PATH="$ROOT/ios_arm64/lib/pkgconfig"
    \
    '--enable-fast-install'
    '--enable-shared=no'
    "--host=$target"
    "--prefix=$ROOT/ios_arm64"
    "--with-jpeg-include-dir=$ROOT/ios_arm64/include"
    "--with-jpeg-lib-dir=$ROOT/ios_arm64/lib"
    '--without-x'
  )

  xc mkdir -p $SOURCES/$name/ios_arm64
  xc cd $SOURCES/$name/ios_arm64

  print -n 'configuring... '
  xl $name '2_config_ios_arm64' ../configure $config_flags || exit 1
  print -n 'done, '

  print -n 'making... '
  xl $name '3_clean_ios_arm64' make clean || exit 1
  xl $name '3_make_ios_arm64' make || exit 1
  print -n 'done, '

  print -n 'installing... '
  xl $name '4_install_ios_arm64' make install || exit 1
  print 'done.'
fi

# --  ios_x86_64  --------------------------------------------------------------
print -n 'ios_x86_64: '

export PKG_CONFIG_PATH=$ROOT/ios_x86_64/lib/pkgconfig
if {
  pkg-config --exists --print-errors 'libtiff-4 >= 4.1.0' &&
    [ -f $ROOT/ios_x86_64/lib/libtiff.a ]
}; then

  print 'skipped config/make/install, found ROOT/ios_x86_64/lib/libtiff.a'

else

  arch='x86_64'
  target='x86_64-apple-darwin'
  platform='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk'
  platform_min_version='-mios-simulator-version-min=11.0'

  cflags=(
    "-arch $arch"
    "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$platform"
    $platform_min_version
    "--target=$target"
    \
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
    LDFLAGS="-L/Applications/Xcode.app/Contents/Developer/Platforms/$platform/usr/lib/"
    PKG_CONFIG_PATH="$ROOT/ios_x86_64/lib/pkgconfig"
    \
    '--enable-fast-install'
    '--enable-shared=no'
    "--host=$target"
    "--prefix=$ROOT/ios_x86_64"
    "--with-jpeg-include-dir=$ROOT/ios_x86_64/include"
    "--with-jpeg-lib-dir=$ROOT/ios_x86_64/lib"
    '--without-x'
  )

  xc mkdir -p $SOURCES/$name/ios_x86_64
  xc cd $SOURCES/$name/ios_x86_64


  print -n 'configuring... '
  xl $name '2_config_ios_x86_64' ../configure $config_flags || exit 1
  print -n 'done, '

  print -n 'making... '
  xl $name '3_clean_ios_x86_64' make clean || exit 1
  xl $name '3_make_ios_x86_64' make || exit 1
  print -n 'done, '

  print -n 'installing... '
  xl $name '4_install_ios_x86_64' make install || exit 1
  print 'done.'
fi

# --  macos_x86_64  --------------------------------------------------------------
print -n 'macos_x86_64: '

export PKG_CONFIG_PATH=$ROOT/macos_x86_64/lib/pkgconfig
if {
  pkg-config --exists --print-errors 'libtiff-4 >= 4.1.0' &&
    [ -f $ROOT/macos_x86_64/lib/libtiff.a ]
}; then

  print 'skipped config/make/install, found ROOT/macos_x86_64/lib/libtiff.a'

else

  arch='x86_64'
  target='x86_64-apple-darwin'
  platform='MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk'
  platform_min_version='-mmacosx-version-min=10.13'

  cflags=(
    "-arch $arch"
    "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$platform"
    $platform_min_version
    "--target=$target"
    \
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
    LDFLAGS="-L/Applications/Xcode.app/Contents/Developer/Platforms/$platform/usr/lib/"
    PKG_CONFIG_PATH="$ROOT/macos_x86_64/lib/pkgconfig"
    \
    '--enable-fast-install'
    '--enable-shared=no'
    "--host=$target"
    "--prefix=$ROOT/macos_x86_64"
    "--with-jpeg-include-dir=$ROOT/macos_x86_64/include"
    "--with-jpeg-lib-dir=$ROOT/macos_x86_64/lib"
    '--without-x'
  )

  xc mkdir -p $SOURCES/$name/macos_x86_64
  xc cd $SOURCES/$name/macos_x86_64


  print -n 'configuring... '
  xl $name '2_config_macos_x86_64' ../configure $config_flags || exit 1
  print -n 'done, '

  print -n 'making... '
  xl $name '3_clean_macos_x86_64' make clean || exit 1
  xl $name '3_make_macos_x86_64' make || exit 1
  print -n 'done, '

  print -n 'installing... '
  xl $name '4_install_macos_x86_64' make install || exit 1
  print 'done.'
fi

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
