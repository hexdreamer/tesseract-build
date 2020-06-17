#!/bin/sh
# shellcheck disable=SC2164,SC2140,2046,2155,2102

curl -L https://downloads.sourceforge.net/project/libpng/libpng16/1.6.36/libpng-1.6.36.tar.gz | tar -xpf-

export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
export CFLAGS="-arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/"

mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/arm-apple-darwin64
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/arm-apple-darwin64
../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=arm-apple-darwin64" --host=arm-apple-darwin64 --enable-shared=no --prefix=$(pwd)

export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
export CFLAGS="-arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mios-simulator-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/"

mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/x86_64-apple-darwin
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/x86_64-apple-darwin
../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --enable-shared=no --prefix=$(pwd)

cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/arm-apple-darwin64
/Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install

cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/x86_64-apple-darwin
/Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install

mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/arm-apple-darwin64/lib/libpng16.a /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/x86_64-apple-darwin/lib/libpng16.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib/libpng.a

mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/dependencies/include
cp -rvf /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/arm-apple-darwin64/include/*.h /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/dependencies/include

curl http://www.ijg.org/files/jpegsrc.v9c.tar.gz | tar -xpf-
export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
export CFLAGS="-arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/arm-apple-darwin64
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/arm-apple-darwin64
../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=arm-apple-darwin64" --host=arm-apple-darwin64 --enable-shared=no --prefix=$(pwd)
export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
export CFLAGS="-arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mios-simulator-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/x86_64-apple-darwin
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/x86_64-apple-darwin
../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --enable-shared=no --prefix=$(pwd)
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/arm-apple-darwin64
/Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/x86_64-apple-darwin
/Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/arm-apple-darwin64/lib/libjpeg.a /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/x86_64-apple-darwin/lib/libjpeg.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib/libjpeg.a
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/dependencies/include
curl http://download.osgeo.org/libtiff/tiff-4.0.10.tar.gz | tar -xpf-
export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
export CFLAGS="-arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/arm-apple-darwin64
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/arm-apple-darwin64
../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=arm-apple-darwin64" --host=arm-apple-darwin64 --enable-fast-install --enable-shared=no --prefix=$(pwd) --without-x --with-jpeg-include-dir=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/arm-apple-darwin64/include --with-jpeg-lib-dir=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/arm-apple-darwin64/lib

export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
export CFLAGS="-arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mios-simulator-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/x86_64-apple-darwin
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/x86_64-apple-darwin
../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --enable-fast-install --enable-shared=no --prefix=$(pwd) --without-x --with-jpeg-include-dir=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/x86_64-apple-darwin/include --with-jpeg-lib-dir=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/x86_64-apple-darwin/lib

cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/arm-apple-darwin64
/Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
1 warning generated.
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/x86_64-apple-darwin
/Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
1 warning generated.
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/arm-apple-darwin64/lib/libtiff.a /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/x86_64-apple-darwin/lib/libtiff.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib/libtiff.a
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/dependencies/include
curl http://leptonica.org/source/leptonica-1.78.0.tar.gz | tar -xpf-

cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0 && ./autogen.sh 2>/dev/null
export LIBS="-lz -lpng -ljpeg -ltiff"
export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
export CFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/include -arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/include -arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min="11.0" -O2 -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/ -L/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib"
export PKG_CONFIG_PATH=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/arm-apple-darwin64/:/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/arm-apple-darwin64/:/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/arm-apple-darwin64/
export CXX="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64"
export CXX_FOR_BUILD="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64"
export CC="""$(xcode-select -p)"/usr/bin/gcc" --target=arm-apple-darwin64"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/arm-apple-darwin64
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/arm-apple-darwin64
../../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=arm-apple-darwin64" --host=arm-apple-darwin64 --prefix=$(pwd) --enable-shared=no --disable-programs --with-zlib --with-libpng --with-jpeg --with-libtiff --without-giflib --without-libwebp
export LIBS="-lz -lpng -ljpeg -ltiff"
export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
export CFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/include -arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mios-simulator-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/include -arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mios-simulator-version-min="11.0" -O2 -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/ -L/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib"
export PKG_CONFIG_PATH=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/x86_64-apple-darwin/:/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/x86_64-apple-darwin/:/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/x86_64-apple-darwin/
export CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
export CXX_FOR_BUILD="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
export CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/x86_64-apple-darwin
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/x86_64-apple-darwin
../../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --prefix=$(pwd) --enable-shared=no --disable-programs --with-zlib --with-libpng --with-jpeg --with-libtiff --without-giflib --without-libwebp
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/arm-apple-darwin64
/Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
17 warnings generated.
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/x86_64-apple-darwin
/Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
17 warnings generated.
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/arm-apple-darwin64/lib/liblept.a /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/x86_64-apple-darwin/lib/liblept.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib/liblept.a
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/include
curl -LO https://github.com/tesseract-ocr/tesseract/archive/4.1.0.zip && unzip -a 4.1.0.zip
5280bbcade4e2dec5eef439a6e189504c2eadcd9
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0 && ./autogen.sh 2>/dev/null

$ ./configure [--enable-debug] [...other options]
export LIBS="-lz -lpng -ljpeg -ltiff"
export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
export CFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/arm-apple-darwin64/ -arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/arm-apple-darwin64/ -arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min="11.0" -O2 -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/ -L/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib -L/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/arm-apple-darwin64/src/.libs"
export LIBLEPT_HEADERSDIR=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/arm-apple-darwin64/
export PKG_CONFIG_PATH=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/arm-apple-darwin64/
export CXX="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64"
export CXX_FOR_BUILD="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64"
export CC="""$(xcode-select -p)"/usr/bin/gcc" --target=arm-apple-darwin64"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/arm-apple-darwin64
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/arm-apple-darwin64
ln -s /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/src/ leptonica
../../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=arm-apple-darwin64" --host=arm-apple-darwin64 --prefix=$(pwd) --enable-shared=no --disable-graphics

$ make
$ sudo make install
$ sudo ldconfig

export LIBS="-lz -lpng -ljpeg -ltiff"
export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
export CFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/x86_64-apple-darwin/ -arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mios-simulator-version-min="11.0" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/x86_64-apple-darwin/ -arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mios-simulator-version-min="11.0" -O2 -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/ -L/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib -L/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/x86_64-apple-darwin/src/.libs"
export LIBLEPT_HEADERSDIR=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/x86_64-apple-darwin/
export PKG_CONFIG_PATH=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/ios/x86_64-apple-darwin/
export CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
export CXX_FOR_BUILD="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
export CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/x86_64-apple-darwin
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/x86_64-apple-darwin
ln -s /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/src/ leptonica
../../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --prefix=$(pwd) --enable-shared=no --disable-graphics

$ make
$ sudo make install
$ sudo ldconfig

cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/arm-apple-darwin64 && /Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
1.0 -O2 -Wno-deprecated-register -std=c++17 -MT drawfx.lo -MD -MP -MF .deps/drawfx.Tpo -c ../../../../src/wordrec/drawfx.cpp -o drawfx.o
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/x86_64-apple-darwin && /Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
version-min=11.0 -O2 -Wno-deprecated-register -std=c++17 -MT mainblk.lo -MD -MP -MF .deps/mainblk.Tpo -c ../../../../src/ccutil/mainblk.cpp -o mainblk.o
lications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk -mios-simulator-version-min=11.0 -O2 -Wno-deprecated-register -std=c++17 -MT cjkpitch.lo -MD -MP -MF .deps/cjkpitch.Tpo -c ../../../../src/textord/cjkpitch.cpp -o cjkpitch.o
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/arm-apple-darwin64/lib/libtesseract.a /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/ios/x86_64-apple-darwin/lib/libtesseract.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib/libtesseract.a
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/include
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/x86_64-apple-darwin/lib/libpng16.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib/libpng.a
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/dependencies/include
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/x86_64-apple-darwin/lib/libjpeg.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib/libjpeg.a
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/dependencies/include
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/x86_64-apple-darwin/lib/libtiff.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib/libtiff.a
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/dependencies/include
export LIBS="-lz -lpng -ljpeg -ltiff"
export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk"
export CFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/include -arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mmacosx-version-min="10.13" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/include -arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mmacosx-version-min="10.13" -O2 -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/ -L/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib"
export PKG_CONFIG_PATH=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/x86_64-apple-darwin/:/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/jpeg-9c/x86_64-apple-darwin/:/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tiff-4.0.10/x86_64-apple-darwin/
export CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
export CXX_FOR_BUILD="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
export CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/macos/x86_64-apple-darwin
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/macos/x86_64-apple-darwin
../../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --prefix=$(pwd) --enable-shared=no --disable-programs --with-zlib --with-libpng --with-jpeg --with-libtiff --without-giflib --without-libwebp
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/macos/x86_64-apple-darwin
/Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
17 warnings generated.
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/macos/x86_64-apple-darwin/lib/liblept.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib/liblept.a
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/include
export LIBS="-lz -lpng -ljpeg -ltiff"
export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk"
export CFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/macos/x86_64-apple-darwin/ -arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mmacosx-version-min="10.13" -O2 -fembed-bitcode"
export CPPFLAGS=$CFLAGS
export CXXFLAGS="-I/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/macos/x86_64-apple-darwin/ -arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -mmacosx-version-min="10.13" -O2 -Wno-deprecated-register"
export LDFLAGS="-L$SDKROOT/usr/lib/ -L/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib -L/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/macos/x86_64-apple-darwin/src/.libs"
export LIBLEPT_HEADERSDIR=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/macos/x86_64-apple-darwin/
export PKG_CONFIG_PATH=/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/macos/x86_64-apple-darwin/
export CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
export CXX_FOR_BUILD="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
export CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin"
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/macos/x86_64-apple-darwin
cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/macos/x86_64-apple-darwin
ln -s /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/leptonica-1.78.0/src/ leptonica
../../configure CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --prefix=$(pwd) --enable-shared=no --disable-graphics

$ make
$ sudo make install
$ sudo ldconfig

cd /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/macos/x86_64-apple-darwin && /Applications/Xcode.app/Contents/Developer/usr/bin/make -sj8 && /Applications/Xcode.app/Contents/Developer/usr/bin/make install
d-register -std=c++17 -MT adaptive.lo -MD -MP -MF .deps/adaptive.Tpo -c ../../../../src/classify/adaptive.cpp -o adaptive.o
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/tesseract-4.1.0/macos/x86_64-apple-darwin/lib/libtesseract.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib/libtesseract.a
mkdir -p /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/include
