# SwiftyTesseract's Build Mechanics

How SwiftyTesseract builds Tesseract OCR and its dependencies.

From the root of SwiftyTesseract, simply running:

```sh
cd ./SwiftyTesseract/SwiftyTesseract/SwiftyTesseract
make
```

produces the following high-level flow for the dependencies of Tesseract-OCR, and finally Tesseract-OCR itself:

1. Download
1. Pre-configure (optional) - Leptonica and Tesseract have autogen.sh scripts to do some preconfiguration, *dunno really what they're doing at the moment*
1. Configure
1. Make - uses the flags: `-s` "silent", `-j8` "8 workers/threads/jobs"
1. Lipo - create one universal "iOS" lib from the ARM and x86 libs

## Platforms & Architectures

The `ios` platform targets both ARM and x86 architectures.  x86 is necessary as it's the architecture for iPhoneSimulator (cross-reference with [BuildNotes.md](./BuildNotes.md#understanding-multi-arch-binaries-and-supported-ios-architectures)):

> Why are Intel slices for iOS a thing? To be able to run your app and the library in the Xcode iOS **simulator**, which actually runs x86 code only. That's why it's *not* called an **"emulator"**.

And the SDK for the x86 build is always `SDKs/iPhoneSimulator13.4.sdk`.

### macOS

To give developers the option to integrate Tesseract-OCR into a desktop app, we're also building for the macOS platform.  In the output of the SwiftyTesseract make log, it looks like the x86 library is "recycled" for macOS:

```sh
# iOS platform phase
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/arm-apple-darwin64/lib/libpng16.a /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/x86_64-apple-darwin/lib/libpng16.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/ios/lib/libpng.a

# macOS platform phase
xcrun lipo /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/libpng-1.6.36/x86_64-apple-darwin/lib/libpng16.a -create -output /Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract/macos/lib/libpng.a
```

I say recycled because the x86 target references the Simulator SDK/sysroot, so I'm not sure this is actually what we want.  Clang also has flags specific to macOS, `-mmacosx-version-min=<arg>, -mmacos-version-min=<arg>`.  There's also a completely different SDK for macOS at `/Applications/Xcode.app/Contents/Developer/Platforms/`.

### Build/Compiler flags

- Command-line options for Clang, like `-miphonesimulator-version-min`, can be found [here][1].  The users manual is [here][2].

- `--enable-shared=no`, gets integrated into the libtool script

### Clang v. LLVM

Taking from SO answers [here][4]:

> LLVM originally stood for "low-level virtual machine", though it now just stands for itself as it has grown to be something other than a traditional virtual machine. It is a set of libraries and tools, as well as a standardized intermediate representation, that can be used to help build compilers and just-in-time compilers. It cannot compile anything other than its own intermediate representation on its own; it needs a language-specific frontend in order to do so.

and,

> LLVM is a backend compiler meant to build compilers on top of it. It deals with optimizations and production of code adapted to the target architecture.
>
> CLang is a front end which parses C, C++ and Objective C code and translates it into a representation suitable for LLVM.

## About this document

The following substitutions were made throughout.

```sh
XCODE_DEV=/Applications/Xcode.app/Contents/Developer
ROOT=/Your/Project/Root
```

and, now...

## The build starts

The build starts off with a platform-specific invocation of `make`:

```sh
{XCODE_DEV}/usr/bin/make platform=ios
```

which proceeds to the dependencies and Tesseract.

## Dependencies

### libpng

1. **Download**

  ```sh
  curl -L https://downloads.sourceforge.net/project/libpng/libpng16/1.6.36/libpng-1.6.36.tar.gz | tar -xpf-
  ```

1. **Configure**
    1. ARM

        ```sh
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
        export CFLAGS="\
            -arch arm64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -miphoneos-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
        export LDFLAGS="-L$SDKROOT/usr/lib/"

        cd {ROOT}/libpng-1.6.36/arm-apple-darwin64
        ../configure \
            CXX="""`xcode-select -p`"/usr/bin/g++" --target=arm-apple-darwin64" \
            CC="""`xcode-select -p`"/usr/bin/gcc" --target=arm-apple-darwin64" \
            --host=arm-apple-darwin64 \
            --enable-shared=no \
            --prefix=`pwd`
        ```

    1. x86

        ```sh
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk" ; \
        export CFLAGS="\
            -arch x86_64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -mios-simulator-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS ; \
        export CXXFLAGS="$CFLAGS -Wno-deprecated-register"; \
        export LDFLAGS="-L$SDKROOT/usr/lib/" ; \

        cd {ROOT}/libpng-1.6.36/x86_64-apple-darwin
        ../configure \
            CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" \
            CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin" \
            --host=x86_64-apple-darwin \
            --enable-shared=no \
            --prefix=`pwd`
        ```

1. **Make**

    1. ARM

        ```sh
        cd {ROOT}/libpng-1.6.36/arm-apple-darwin64
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
            ...
        {XCODE_DEV}/usr/bin/make  install-am
            ...
        {XCODE_DEV}/usr/bin/make  install-exec-hook
            ...
        {XCODE_DEV}/usr/bin/make  install-data-hook
            ...
        ```

    1. x86

        ```sh
        cd {ROOT}/libpng-1.6.36/x86_64-apple-darwin
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
            ...
        {XCODE_DEV}/usr/bin/make  install-am
            ...
        {XCODE_DEV}/usr/bin/make  install-exec-hook
            ...
        {XCODE_DEV}/usr/bin/make  install-data-hook
            ...
        ```

1. **lipo**

    ```sh
    xcrun lipo \
    {ROOT}/libpng-1.6.36/arm-apple-darwin64/lib/libpng16.a \
    {ROOT}/libpng-1.6.36/x86_64-apple-darwin/lib/libpng16.a \
    -create \
    -output \
    {ROOT}/ios/lib/libpng.a
    ```

### libjpeg

1. **Download**

    ```sh
    curl http://www.ijg.org/files/jpegsrc.v9c.tar.gz | tar -xpf-
    ```

1. **Configure**

    1. ARM

        ```sh
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
        export CFLAGS="\
            -arch arm64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -miphoneos-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
        export LDFLAGS="-L$SDKROOT/usr/lib/"

        cd {ROOT}/jpeg-9c/arm-apple-darwin64
        ../configure \
            CXX="""`xcode-select -p`"/usr/bin/g++" --target=arm-apple-darwin64" \
            CC="""`xcode-select -p`"/usr/bin/gcc" --target=arm-apple-darwin64" \
            --host=arm-apple-darwin64 \
            --enable-shared=no \
            --prefix=`pwd`
        ```

    2. x86

        ```sh
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
        export CFLAGS="\
            -arch x86_64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -mios-simulator-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
        export LDFLAGS="-L$SDKROOT/usr/lib/"

        cd {ROOT}/jpeg-9c/x86_64-apple-darwin
        ../configure \
            CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" \
            CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin" \
            --host=x86_64-apple-darwin \
            --enable-shared=no \
            --prefix=`pwd`
        ```

1. **Make**

    1. ARM

        ```sh
        cd {ROOT}/jpeg-9c/arm-apple-darwin64
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
        ```

    1. x86

        ```sh
        cd {ROOT}/jpeg-9c/x86_64-apple-darwin
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
        ```

1. **Lipo**

    ```sh
    xcrun lipo \
    {ROOT}/jpeg-9c/arm-apple-darwin64/lib/libjpeg.a \
    {ROOT}/jpeg-9c/x86_64-apple-darwin/lib/libjpeg.a \
    -create \
    -output \
    {ROOT}/ios/lib/libjpeg.a
    ```

### libtiff

1. **Download**

    ```sh
    curl http://download.osgeo.org/libtiff/tiff-4.0.10.tar.gz | tar -xpf-
    ```

1. **Configure**

    1. ARM

        ```sh
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
        export CFLAGS="\
            -arch arm64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -miphoneos-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
        export LDFLAGS="-L$SDKROOT/usr/lib/"

        cd {ROOT}/tiff-4.0.10/arm-apple-darwin64
        ../configure \
            CXX="""`xcode-select -p`"/usr/bin/g++" --target=arm-apple-darwin64" \
            CC="""`xcode-select -p`"/usr/bin/gcc" --target=arm-apple-darwin64" \
            -host=arm-apple-darwin64 \
            --enable-fast-install \
            --enable-shared=no \
            --prefix=`pwd` \
            --without-x \
            --with-jpeg-include-dir={ROOT}/jpeg-9c/arm-apple-darwin64/include \
            --with-jpeg-lib-dir={ROOT}/jpeg-9c/arm-apple-darwin64/lib
        ```

    2. x86

        ```sh
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
        export CFLAGS="\
            -arch x86_64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -mios-simulator-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS="$CFLAGS -Wno-deprecated-register"
        export LDFLAGS="-L$SDKROOT/usr/lib/"

        cd {ROOT}/tiff-4.0.10/x86_64-apple-darwin
        ../configure \
            CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" \
            CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin" \
            --host=x86_64-apple-darwin \
            --enable-fast-install \
            --enable-shared=no \
            --prefix=`pwd` \
            --without-x \
            --with-jpeg-include-dir={ROOT}/jpeg-9c/x86_64-apple-darwin/include \
            --with-jpeg-lib-dir={ROOT}/jpeg-9c/x86_64-apple-darwin/lib
        ```

1. **Make**

    1. ARM

        ```sh
        cd {ROOT}/tiff-4.0.10/arm-apple-darwin64
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
        ```

    1. x86

        ```sh
        cd {ROOT}/tiff-4.0.10/x86_64-apple-darwin
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
        ```

1. **lipo**

    ```sh
    xcrun lipo \
    {ROOT}/tiff-4.0.10/arm-apple-darwin64/lib/libtiff.a \
    {ROOT}/tiff-4.0.10/x86_64-apple-darwin/lib/libtiff.a \
    -create \
    -output \
    {ROOT}/ios/lib/libtiff.a
    ```

### leptonica

1. **Download**

    ```sh
    curl http://leptonica.org/source/leptonica-1.78.0.tar.gz | tar -xpf-
    ```

1. **Pre-Configure**

    ```sh
    cd {ROOT}/leptonica-1.78.0
    ./autogen.sh 2> /dev/null
    ```

1. **Configure**

    1. ARM

        I did notice that flags like `CC` and `CXX` are exported *and* included in-line as positional arguments to configure.  I might experiment with removing one or the other and seeing if there's any difference.  I'd like to see a unified configuration, but maybe individual config processes will not permit.

        ```sh
        export LIBS="-lz -lpng -ljpeg -ltiff"
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
        export CFLAGS="\
            -I{ROOT}/ios/include \
            -arch arm64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -miphoneos-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS="-I{ROOT}/ios/include \
            -arch arm64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -miphoneos-version-min="11.0" \
            -O2 \
            -Wno-deprecated-register"; \
        export LDFLAGS="
            -L$SDKROOT/usr/lib/ \
            -L{ROOT}/ios/lib"
        export PKG_CONFIG_PATH="\
            {ROOT}/libpng-1.6.36/arm-apple-darwin64/:\
            {ROOT}/jpeg-9c/arm-apple-darwin64/:\
            {ROOT}/tiff-4.0.10/arm-apple-darwin64/"
        export CXX="""`xcode-select -p`"/usr/bin/g++" --target=arm-apple-darwin64"
        export CXX_FOR_BUILD="""`xcode-select -p`"/usr/bin/g++" --target=arm-apple-darwin64"
        export CC="""`xcode-select -p`"/usr/bin/gcc" --target=arm-apple-darwin64"

        mkdir -p {ROOT}/leptonica-1.78.0/ios/arm-apple-darwin64--
        cd {ROOT}/leptonica-1.78.0/ios/arm-apple-darwin64

        ../../configure \
            CXX="""`xcode-select -p`"/usr/bin/g++" --target=arm-apple-darwin64" \
            CC="""`xcode-select -p`"/usr/bin/gcc" --target=arm-apple-darwin64" \
            --host=arm-apple-darwin64 \
            --prefix=`pwd` \
            --enable-shared=no \
            --disable-programs \
            --with-zlib \
            --with-libpng \
            --with-jpeg \
            --with-libtiff \
            --without-giflib \
            --without-libwebp
        ```

    2. x86

        ```sh
        export LIBS="-lz -lpng -ljpeg -ltiff"
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
        export CFLAGS="\
            -I{ROOT}/ios/include \
            -arch x86_64 \n-pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -mios-simulator-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS="\
            -I{ROOT}/ios/include \
            -arch x86_64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -mios-simulator-version-min="11.0" \
            -O2 \
            -Wno-deprecated-register"
        export LDFLAGS="\
            -L$SDKROOT/usr/lib/ \
            -L{ROOT}/ios/lib"
        export PKG_CONFIG_PATH="\
            {ROOT}/libpng-1.6.36/x86_64-apple-darwin/:\
            {ROOT}/jpeg-9c/x86_64-apple-darwin/:\
            {ROOT}/tiff-4.0.10/x86_64-apple-darwin/"
        export CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin"
        export CXX_FOR_BUILD="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin"
        export CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin"

        mkdir -p {ROOT}/leptonica-1.78.0/ios/x86_64-apple-darwin
        cd {ROOT}/leptonica-1.78.0/ios/x86_64-apple-darwin

        ../../configure \
            CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" \
            CC="""`xcode-select -p`"/usr/bin/gcc" \
            --target=x86_64-apple-darwin" \
            --host=x86_64-apple-darwin \
            --prefix=`pwd` \
            --enable-shared=no \
            --disable-programs \
            --with-zlib \
            --with-libpng \
            --with-jpeg \
            --with-libtiff \
            --without-giflib \
            --without-libwebp
        ```

1. **Make**

    1. ARM

        ```sh
        cd {ROOT}/leptonica-1.78.0/ios/arm-apple-darwin64
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
        ```

    1. x86

        ```sh
        cd {ROOT}/leptonica-1.78.0/ios/x86_64-apple-darwin
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
        ```

1. **Lipo**

    ```sh
    xcrun lipo \
    {ROOT}/leptonica-1.78.0/ios/arm-apple-darwin64/lib/liblept.a \
    {ROOT}/leptonica-1.78.0/ios/x86_64-apple-darwin/lib/liblept.a \
    -create \
    -output \
    {ROOT}/ios/lib/liblept.a
    ```

## Tesseract-OCR

1. **Download**

    ```sh
    curl -LO https://github.com/tesseract-ocr/tesseract/archive/4.1.0.zip && unzip -a 4.1.0.zip
    ```

1. **Pre-Configure**

    ```sh
    cd {ROOT}/tesseract-4.1.0
    ./autogen.sh 2>/dev/null
    ```

1. **Configure**

    1. ARM

        ```sh
        export LIBS="-lz -lpng -ljpeg -ltiff"
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
        export CFLAGS="\
            -I{ROOT}/tesseract-4.1.0/ios/arm-apple-darwin64/ \
            -arch arm64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -miphoneos-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS="\
            -I{ROOT}/tesseract-4.1.0/ios/arm-apple-darwin64/ \
            -arch arm64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -miphoneos-version-min="11.0" \
            -O2 \
            -Wno-deprecated-register"
        export LDFLAGS="\
            -L$SDKROOT/usr/lib/ \
            -L{ROOT}/ios/lib \
            -L{ROOT}/leptonica-1.78.0/ios/arm-apple-darwin64/src/.libs"
        export LIBLEPT_HEADERSDIR={ROOT}/tesseract-4.1.0/ios/arm-apple-darwin64/
        export PKG_CONFIG_PATH={ROOT}/leptonica-1.78.0/ios/arm-apple-darwin64/
        export CXX="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64"
        export CXX_FOR_BUILD="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64"
        export CC="""$(xcode-select -p)"/usr/bin/gcc" --target=arm-apple-darwin64"

        mkdir -p {ROOT}/tesseract-4.1.0/ios/arm-apple-darwin64
        cd {ROOT}/tesseract-4.1.0/ios/arm-apple-darwin64
        ln -s {ROOT}/leptonica-1.78.0/src/ leptonica

        ../../configure \
            CXX="""$(xcode-select -p)"/usr/bin/g++" --target=arm-apple-darwin64" \
            CC="""$(xcode-select -p)"/usr/bin/gcc" \
            --target=arm-apple-darwin64" \
            --host=arm-apple-darwin64 \
            --prefix=$(pwd) \
            --enable-shared=no \
            --disable-graphics
        ```

    2. x86

        ```sh
        export LIBS="-lz -lpng -ljpeg -ltiff"
        export SDKROOT="{XCODE_DEV}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
        export CFLAGS="\
            -I{ROOT}/tesseract-4.1.0/ios/x86_64-apple-darwin/ \
            -arch x86_64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -mios-simulator-version-min="11.0" \
            -O2 \
            -fembed-bitcode"
        export CPPFLAGS=$CFLAGS
        export CXXFLAGS="\
            -I{ROOT}/tesseract-4.1.0/ios/x86_64-apple-darwin/ \
            -arch x86_64 \
            -pipe \
            -no-cpp-precomp \
            -isysroot $SDKROOT \
            -mios-simulator-version-min="11.0" \
            -O2 \
            -Wno-deprecated-register"
        export LDFLAGS="\
            -L$SDKROOT/usr/lib/ \
            -L{ROOT}/ios/lib \
            -L{ROOT}/leptonica-1.78.0/ios/x86_64-apple-darwin/src/.libs"
        export LIBLEPT_HEADERSDIR={ROOT}/tesseract-4.1.0/ios/x86_64-apple-darwin/
        export PKG_CONFIG_PATH={ROOT}/leptonica-1.78.0/ios/x86_64-apple-darwin/
        export CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
        export CXX_FOR_BUILD="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin"
        export CC="""$(xcode-select -p)"/usr/bin/gcc" --target=x86_64-apple-darwin"

        mkdir -p {ROOT}/tesseract-4.1.0/ios/x86_64-apple-darwin
        cd {ROOT}/tesseract-4.1.0/ios/x86_64-apple-darwin
        ln -s {ROOT}/leptonica-1.78.0/src/ leptonica

        ../../configure \
            CXX="""$(xcode-select -p)"/usr/bin/g++" --target=x86_64-apple-darwin" \
            CC="""$(xcode-select -p)"/usr/bin/gcc" \
            --target=x86_64-apple-darwin" \
            --host=x86_64-apple-darwin \
            --prefix=$(pwd) \
            --enable-shared=no \
            --disable-graphics
        ```

1. **Make**

    1. ARM

        ```sh
        cd {ROOT}/tesseract-4.1.0/ios/arm-apple-darwin64
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
        ```

    1. x86

        ```sh
        cd {ROOT}/tesseract-4.1.0/ios/x86_64-apple-darwin
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
        ```

1. **Lipo**

    ```sh
    mkdir -p {ROOT}/ios/lib
    xcrun lipo \
    {ROOT}/tesseract-4.1.0/ios/arm-apple-darwin64/lib/libtesseract.a \
    {ROOT}/tesseract-4.1.0/ios/x86_64-apple-darwin/lib/libtesseract.a \
    -create \
    -output \
    {ROOT}/ios/lib/libtesseract.a
    ```

## Miscellaneous

### About this MD

The input for this MD file was assembled from the filtered commands created by running the following `grep` against the full output of `../make.log`, which was captured by running SwiftyTesseract's `make > make.log 2>&1`:

```sh
grep -v -E \
'^checking |'\
'^config|'\
'libtool|'\
'^\+ |'\
'^ .*|'\
'^/|'\
'^make|'\
'^\.\./|'\
'^cp|'\
'^#define|'\
'^[A-Z]' \
make.log | shFmt > swifty-make-subtractive.txt
```

`shFmt` was used to normalize the text to the extent it could.

These commands were then hand-edited and organized into the this document.

[1]: https://clang.llvm.org/docs/ClangCommandLineReference.html
[2]: https://clang.llvm.org/docs/UsersManual.html
[3]: https://llvm.org/docs/Packaging.html
[4]: https://stackoverflow.com/questions/5708610/llvm-vs-clang-on-os-x