#!/bin/zsh -f

# LEPTONICA -- https://github.com/DanBloomberg/leptonica

scriptname=$0:A
parentdir=${scriptname%/build_leptonica.sh}
if ! source $parentdir/project_environment.sh; then
  echo "build_leptonica.sh: error sourcing $parentdir/project_environment.sh"
  exit 1
fi

if ! source $SCRIPTSDIR/utility.sh; then
  echo "build_leptonica.sh: error sourcing $SCRIPTSDIR/utility.sh"
  exit 1
fi

local name='leptonica-1.79.0'
print "\n======== $name ========"

# Being respectful of hosts and their bandwidth
targz=$name.tar.gz
if [ -e $DOWNLOADS/$targz ]; then
  echo "Skipped download, using cached $targz in Downloads."
else
  print -n 'Downloading...'
  url="https://github.com/danbloomberg/leptonica/releases/download/1.79.0/$targz"
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

xc cd $SOURCES/$name

xl $name '2_preconfig' ./autogen.sh || exit 1

# --  ios_arm64  --------------------------------------------------------------
print -n 'ios_arm64: '

export PKG_CONFIG_PATH=$ROOT/ios_arm64/lib/pkgconfig
if {
  pkg-config --exists --print-errors 'lept >= 1.79.0' &&
    [ -f $ROOT/ios_arm64/lib/liblept.a ]
}; then

  print 'skipped config/make/install, found ROOT/ios_arm64/lib/liblept.a'

else

  arch='arm64'
  target='arm-apple-darwin64'
  platform='iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk'
  platform_min_version='-miphoneos-version-min=11.0'

  cflags=(
    "-arch $arch"
    "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$platform"
    "-I$ROOT/ios_arm64/include"
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
    CXX_FOR_BUILD="$(xcode-select -p)/usr/bin/g++"
    CFLAGS="$cflags"
    CPPFLAGS="$cflags"
    CXXFLAGS="$cflags -Wno-deprecated-register"
    LDFLAGS="-L$ROOT/ios_arm64/lib -L/Applications/Xcode.app/Contents/Developer/Platforms/$platform/usr/lib/"
    LIBS='-lz -lpng -ljpeg -ltiff'
    PKG_CONFIG_PATH="$ROOT/ios_arm64/lib/pkgconfig"
    \
    "--host=$target"
    "--prefix=$ROOT/ios_arm64"
    \
    '--disable-programs'
    '--enable-shared=no'
    '--with-jpeg'
    '--with-libpng'
    '--with-libtiff'
    '--with-zlib'
    '--without-giflib'
    '--without-libwebp'
  )

  xc mkdir -p $SOURCES/$name/ios_arm64
  xc cd $SOURCES/$name/ios_arm64

  print -n 'configuring... '
  xl $name '3_config_ios_arm64' ../configure $config_flags || exit 1
  print -n 'done, '

  print -n 'making... '
  xl $name '4_clean_ios_arm64' make clean || exit 1
  xl $name '4_make_ios_arm64' make || exit 1
  print -n 'done, '

  print -n 'installing... '
  xl $name '5_install_ios_arm64' make install || exit 1
  print 'done.'
fi

# --  ios_x86_64  --------------------------------------------------------------
print -n 'ios_x86_64: '

export PKG_CONFIG_PATH=$ROOT/ios_x86_64/lib/pkgconfig
if {
  pkg-config --exists --print-errors 'lept >= 1.79.0' &&
    [ -f $ROOT/ios_x86_64/lib/liblept.a ]
}; then

  print 'skipped config/make/install, found ROOT/ios_x86_64/lib/liblept.a'

else

  arch='x86_64'
  target='x86_64-apple-darwin'
  platform='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk'
  platform_min_version='-mios-simulator-version-min=11.0'

  cflags=(
    "-arch $arch"
    "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$platform"
    "-I$ROOT/ios_x86_64/include"
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
    CXX_FOR_BUILD="$(xcode-select -p)/usr/bin/g++"
    CFLAGS="$cflags"
    CPPFLAGS="$cflags"
    CXXFLAGS="$cflags -Wno-deprecated-register"
    LDFLAGS="-L$ROOT/ios_x86_64/lib -L/Applications/Xcode.app/Contents/Developer/Platforms/$platform/usr/lib/"
    LIBS='-lz -lpng -ljpeg -ltiff'
    PKG_CONFIG_PATH="$ROOT/ios_x86_64/lib/pkgconfig"
    \
    "--host=$target"
    "--prefix=$ROOT/ios_x86_64"
    \
    '--disable-programs'
    '--enable-shared=no'
    '--with-jpeg'
    '--with-libpng'
    '--with-libtiff'
    '--with-zlib'
    '--without-giflib'
    '--without-libwebp'
  )

  xc mkdir -p $SOURCES/$name/ios_x86_64
  xc cd $SOURCES/$name/ios_x86_64

  print -n 'configuring... '
  xl $name '3_config_ios_x86_64' ../configure $config_flags || exit 1
  print -n 'done, '

  print -n 'making... '
  xl $name '4_clean_ios_x86_64' make clean || exit 1
  xl $name '4_make_ios_x86_64' make || exit 1
  print -n 'done, '

  print -n 'installing... '
  xl $name '5_install_ios_x86_64' make install || exit 1
  print 'done.'
fi

# --  macos_x86_64  --------------------------------------------------------------
print -n 'macos_x86_64: '

export PKG_CONFIG_PATH=$ROOT/macos_x86_64/lib/pkgconfig
if {
  pkg-config --exists --print-errors 'lept >= 1.79.0' &&
    [ -f $ROOT/macos_x86_64/lib/liblept.a ]
}; then

  print 'skipped config/make/install, found ROOT/macos_x86_64/lib/liblept.a'

else

  arch='x86_64'
  target='x86_64-apple-darwin'
  platform='MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk'
  platform_min_version='-mmacosx-version-min=10.13'

  cflags=(
    "-arch $arch"
    "-isysroot /Applications/Xcode.app/Contents/Developer/Platforms/$platform"
    "-I$ROOT/macos_x86_64/include"
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
    CXX_FOR_BUILD="$(xcode-select -p)/usr/bin/g++"
    CFLAGS="$cflags"
    CPPFLAGS="$cflags"
    CXXFLAGS="$cflags -Wno-deprecated-register"
    LDFLAGS="-L$ROOT/macos_x86_64/lib -L/Applications/Xcode.app/Contents/Developer/Platforms/$platform/usr/lib/"
    LIBS='-lz -lpng -ljpeg -ltiff'
    PKG_CONFIG_PATH="$ROOT/macos_x86_64/lib/pkgconfig"
    \
    "--host=$target"
    "--prefix=$ROOT/macos_x86_64"
    \
    '--disable-programs'
    '--enable-shared=no'
    '--with-jpeg'
    '--with-libpng'
    '--with-libtiff'
    '--with-zlib'
    '--without-giflib'
    '--without-libwebp'
  )

  xc mkdir -p $SOURCES/$name/macos_x86_64
  xc cd $SOURCES/$name/macos_x86_64

  print -n 'configuring... '
  xl $name '3_config_macos_x86_64' ../configure $config_flags || exit 1
  print -n 'done, '

  print -n 'making... '
  xl $name '4_clean_macos_x86_64' make clean || exit 1
  xl $name '4_make_macos_x86_64' make || exit 1
  print -n 'done, '

  print -n 'installing... '
  xl $name '5_install_macos_x86_64' make install || exit 1
  print 'done.'
fi

# --  Lipo  -------------------------------------------------------------------
xc mkdir -p $ROOT/lib

print -n 'ios: lipo... '
xl $name '6_lipo_ios' \
  xcrun lipo $ROOT/ios_arm64/lib/liblept.a $ROOT/ios_x86_64/lib/liblept.a \
  -create -output $ROOT/lib/liblept.a ||
  exit 1
print 'done.'

print -n 'macos: lipo... '
xl $name '6_lipo_macos' \
  xcrun lipo $ROOT/macos_x86_64/lib/liblept.a \
  -create -output $ROOT/lib/liblept-macos.a ||
  exit 1
print 'done.'
