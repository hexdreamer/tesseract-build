import unittest

from parse_make import parse_make

input='''
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
'''

class TestParseMake(unittest.TestCase):
    def setUp(self):
        self.lines = input.splitlines()

    def test_extract_target(self):
        config_map = parse_make(self.lines)

        config_target_key = 'configure: CXX="""$(xcode-select -p)"/usr/bin/g++" --target=$TARGET"'
        self.assertIn(config_target_key, config_map)
        self.assertEqual(config_map[config_target_key], ['libpng-1.6.36,arm64', 'libpng-1.6.36,x86_64'])

        self.assertIn('export TARGET: arm-apple-darwin64', config_map)
        self.assertEqual(config_map['export TARGET: arm-apple-darwin64'], ['libpng-1.6.36,arm64'])

        self.assertIn('export TARGET: x86_64-apple-darwin', config_map)
        self.assertEqual(config_map['export TARGET: x86_64-apple-darwin'], ['libpng-1.6.36,x86_64'])