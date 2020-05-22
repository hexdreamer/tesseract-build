import unittest

from parse_make import parse_make

input = '''
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


class TestExtractVars(unittest.TestCase):
    def setUp(self):
        self.lines = input.splitlines()
        self.config_map = parse_make(self.lines)

    def test_ARCH(self):
        config_map = self.config_map

        self.assertIn('export ARCH: arm64', config_map)
        self.assertEqual(
            config_map['export ARCH: arm64'], ['libpng-1.6.36,ios_arm64'])
        self.assertEqual(
            config_map['export CFLAGS: -arch $ARCH'],
            ['libpng-1.6.36,ios_arm64', 'libpng-1.6.36,ios_x86_64'])

        self.assertIn('export ARCH: x86_64', config_map)
        self.assertEqual(
            config_map['export ARCH: x86_64'], ['libpng-1.6.36,ios_x86_64'])

    def test_PLATFORM(self):
        config_map = self.config_map

        export_platform_key='export PLATFORM: iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk'
        self.assertIn(export_platform_key, config_map)
        self.assertEqual(
            config_map[export_platform_key], ['libpng-1.6.36,ios_arm64'])

        export_platform_key='export PLATFORM: iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk'
        self.assertIn(export_platform_key, config_map)
        self.assertEqual(
            config_map[export_platform_key], ['libpng-1.6.36,ios_x86_64'])

        self.assertEqual(
            config_map['export SDKROOT: \"{XCODE_DEV}/Platforms/$PLATFORM\"'],
            ['libpng-1.6.36,ios_arm64', 'libpng-1.6.36,ios_x86_64'])

    def test_PLATFORM_VERSION(self):
        config_map = self.config_map

        export_platform_version='export PLATFORM_VERSION: -miphoneos-version-min="11.0"'
        self.assertIn(export_platform_version, config_map)
        self.assertEqual(
            config_map[export_platform_version], ['libpng-1.6.36,ios_arm64'])

        export_platform_version='export PLATFORM_VERSION: -mios-simulator-version-min="11.0"'
        self.assertIn(export_platform_version, config_map)
        self.assertEqual(
            config_map[export_platform_version], ['libpng-1.6.36,ios_x86_64'])

        self.assertEqual(
            config_map['export CFLAGS: $PLATFORM_VERSION'],
            ['libpng-1.6.36,ios_arm64', 'libpng-1.6.36,ios_x86_64'])

    def test_TARGET(self):
        config_map = self.config_map

        config_target_key = 'configure: CXX="""$(xcode-select -p)"/usr/bin/g++" --target=$TARGET"'
        self.assertIn(config_target_key, config_map)
        self.assertEqual(
            config_map[config_target_key],
            ['libpng-1.6.36,ios_arm64', 'libpng-1.6.36,ios_x86_64'])

        self.assertIn('export TARGET: arm-apple-darwin64', config_map)
        self.assertEqual(
            config_map['export TARGET: arm-apple-darwin64'],
            ['libpng-1.6.36,ios_arm64'])

        self.assertIn('export TARGET: x86_64-apple-darwin', config_map)
        self.assertEqual(
            config_map['export TARGET: x86_64-apple-darwin'],
            ['libpng-1.6.36,ios_x86_64'])
