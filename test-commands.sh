#!/bin/zsh -f

curl -L -f http://www.ijg.org/files/jpegsrc.v9d.tar.gz --output /Users/zyoung/dev/tesseract-build/Downloads/jpegsrc.v9d.tar.gz
tar -zxf /Users/zyoung/dev/tesseract-build/Downloads/jpegsrc.v9d.tar.gz --directory /Users/zyoung/dev/tesseract-build/Sources
mkdir -p /Users/zyoung/dev/tesseract-build/Sources/jpeg-9d/ios_arm64
cd /Users/zyoung/dev/tesseract-build/Sources/jpeg-9d/ios_arm64

../configure \
  CC='/Applications/Xcode.app/Contents/Developer/usr/bin/gcc' \
  CXX='/Applications/Xcode.app/Contents/Developer/usr/bin/g++' \
  CFLAGS='-arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk -miphoneos-version-min=11.0 --target=arm-apple-darwin64 -fembed-bitcode -no-cpp-precomp -O2 -pipe' \
  CPPFLAGS='-arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk -miphoneos-version-min=11.0 --target=arm-apple-darwin64 -fembed-bitcode -no-cpp-precomp -O2 -pipe' \
  CXXFLAGS='-arch arm64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk -miphoneos-version-min=11.0 --target=arm-apple-darwin64 -fembed-bitcode -no-cpp-precomp -O2 -pipe -Wno-deprecated-register' \
  LDFLAGS='-L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.5.sdk/usr/lib/' \
  PKG_CONFIG_PATH='/Users/zyoung/dev/tesseract-build/Root/ios_arm64/lib/pkgconfig' \
  --host=arm-apple-darwin64 \
  --enable-shared=no \
  --prefix=/Users/zyoung/dev/tesseract-build/Root/ios_arm64

make clean
make
make install

# mkdir -p /Users/zyoung/dev/tesseract-build/Sources/jpeg-9d/ios_x86_64
# cd /Users/zyoung/dev/tesseract-build/Sources/jpeg-9d/ios_x86_64

# ../configure CC=/Applications/Xcode.app/Contents/Developer/usr/bin/gcc CXX=/Applications/Xcode.app/Contents/Developer/usr/bin/g++ CFLAGS=-arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk -mios-simulator-version-min=11.0 --target=x86_64-apple-darwin -fembed-bitcode -no-cpp-precomp -O2 -pipe CPPFLAGS=-arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk -mios-simulator-version-min=11.0 --target=x86_64-apple-darwin -fembed-bitcode -no-cpp-precomp -O2 -pipe CXXFLAGS=-arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk -mios-simulator-version-min=11.0 --target=x86_64-apple-darwin -fembed-bitcode -no-cpp-precomp -O2 -pipe -Wno-deprecated-register LDFLAGS=-L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.5.sdk/usr/lib/ PKG_CONFIG_PATH=/Users/zyoung/dev/tesseract-build/Root/ios_x86_64/lib/pkgconfig --host=x86_64-apple-darwin --enable-shared=no --prefix=/Users/zyoung/dev/tesseract-build/Root/ios_x86_64
# make clean
# make
# make install

# mkdir -p /Users/zyoung/dev/tesseract-build/Sources/jpeg-9d/macos_x86_64
# cd /Users/zyoung/dev/tesseract-build/Sources/jpeg-9d/macos_x86_64

# ../configure CC=/Applications/Xcode.app/Contents/Developer/usr/bin/gcc CXX=/Applications/Xcode.app/Contents/Developer/usr/bin/g++ CFLAGS=-arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk -mmacosx-version-min=10.13 --target=x86_64-apple-darwin -fembed-bitcode -no-cpp-precomp -O2 -pipe CPPFLAGS=-arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk -mmacosx-version-min=10.13 --target=x86_64-apple-darwin -fembed-bitcode -no-cpp-precomp -O2 -pipe CXXFLAGS=-arch x86_64 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk -mmacosx-version-min=10.13 --target=x86_64-apple-darwin -fembed-bitcode -no-cpp-precomp -O2 -pipe -Wno-deprecated-register LDFLAGS=-L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk/usr/lib/ PKG_CONFIG_PATH=/Users/zyoung/dev/tesseract-build/Root/macos_x86_64/lib/pkgconfig --host=x86_64-apple-darwin --enable-shared=no --prefix=/Users/zyoung/dev/tesseract-build/Root/macos_x86_64
# make clean
# make
# make install
# mkdir -p /Users/zyoung/dev/tesseract-build/Root/lib
# xcrun lipo /Users/zyoung/dev/tesseract-build/Root/ios_arm64/lib/libjpeg.a /Users/zyoung/dev/tesseract-build/Root/ios_x86_64/lib/libjpeg.a -create -output /Users/zyoung/dev/tesseract-build/Root/lib/libjpeg.a
# xcrun lipo /Users/zyoung/dev/tesseract-build/Root/macos_x86_64/lib/libjpeg.a -create -output /Users/zyoung/dev/tesseract-build/Root/lib/libjpeg-macos.a