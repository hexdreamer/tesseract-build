# SwiftyTesseract's Build Mechanics

How SwiftyTesseract builds Tesseract OCR and its dependencies.

The input for this MD file was assembled from the filtered commands created by running the following `grep` against the full output (../make.log) after running SwiftyTesseract's `make`:

```sh
grep -C1 -E \\./configure\|usr/bin/make\|autogen make.log > swifty-make.txt
```

These commands were then hand-edited and organized into the following document.

To try and make the sequence of steps clear and concise, the following substitutions were made throughout.

```sh
XCODE_DEV=/Applications/Xcode.app/Contents/Developer
ROOT=/Your/Project/Root
```

## The build starts

The build starts off with a platform-specific `make` invocation.  As this project is only concerend with iOS, it ignores the same set of steps that produce build artifacts for macOS.

```sh
{XCODE_DEV}/usr/bin/make platform=ios
```

Then proceeds to the following dependencies.

## Dependencies

### libpng

1. **Download**

  ```sh
  curl -L https://downloads.sourceforge.net/project/libpng/libpng16/1.6.36/libpng-1.6.36.tar.gz | tar -xpf-
  ```

1. **Configure**
    1. ARM

        ```sh
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
        cd {ROOT}/libpng-1.6.36/x86_64-apple-darwin
        ../configure \
            CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" \
            CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin" \
            --host=x86_64-apple-darwin \
            --enable-shared=no \
            --prefix=`pwd`
        ```

1. **Make**, `-sj8` means `-s` "silent", `-j8` "8 workers/threads/jobs"

    1. ARM

        ```sh
        cd {ROOT}/libpng-1.6.36/arm-apple-darwin64
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
            libtool: compile:  {XCODE_DEV}/usr/bin/gcc --target=arm-apple-darwin64 -DHAVE_CONFIG_H -I. -I.. -arch arm64 -pipe -no-cpp-precomp -isysroot {XCODE_DEV}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk -miphoneos-version-min=11.0 -O2 -fembed-bitcode -arch arm64 -pipe -no-cpp-precomp -isysroot {XCODE_DEV}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk -miphoneos-version-min=11.0 -O2 -fembed-bitcode -MT pngget.lo -MD -MP -MF .deps/pngget.Tpo -c ../pngget.c -o pngget.o
            ...
        {XCODE_DEV}/usr/bin/make  install-am
            ../install-sh -c -d '{ROOT}/libpng-1.6.36/arm-apple-darwin64/lib'
            ...
        {XCODE_DEV}/usr/bin/make  install-exec-hook
            + cd {ROOT}/libpng-1.6.36/arm-apple-darwin64/lib
            ...
        {XCODE_DEV}/usr/bin/make  install-data-hook
            + cd {ROOT}/libpng-1.6.36/arm-apple-darwin64/include
            ...
        ```

    1. x86

        ```sh
        cd {ROOT}/libpng-1.6.36/x86_64-apple-darwin
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
            libtool: compile:  {XCODE_DEV}/usr/bin/gcc --target=x86_64-apple-darwin -DHAVE_CONFIG_H -I. -I.. -arch x86_64 -pipe -no-cpp-precomp -isysroot {XCODE_DEV}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk -mios-simulator-version-min=11.0 -O2 -fembed-bitcode -arch x86_64 -pipe -no-cpp-precomp -isysroot {XCODE_DEV}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk -mios-simulator-version-min=11.0 -O2 -fembed-bitcode -MT pngerror.lo -MD -MP -MF .deps/pngerror.Tpo -c ../pngerror.c -o pngerror.o
            ...
        {XCODE_DEV}/usr/bin/make  install-am
            ../install-sh -c -d '{ROOT}/libpng-1.6.36/x86_64-apple-darwin/lib'
            ...
        {XCODE_DEV}/usr/bin/make  install-exec-hook
            + cd {ROOT}/libpng-1.6.36/x86_64-apple-darwin/lib
            ...
        {XCODE_DEV}/usr/bin/make  install-data-hook
            + cd {ROOT}/libpng-1.6.36/x86_64-apple-darwin/include
            ...
        ```

### libjpeg

1. **Configure**

    1. ARM

        ```sh
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
            CC       jaricom.lo
            ...
        ```

    1. x86

        ```sh
        cd {ROOT}/jpeg-9c/x86_64-apple-darwin
        {XCODE_DEV}/usr/bin/make -sj8
        {XCODE_DEV}/usr/bin/make install
            CC       jaricom.lo
            ...
        ```

    cd {ROOT}/tiff-4.0.10/arm-apple-darwin64 ; \
    ../configure CXX="""`xcode-select -p`"/usr/bin/g++" --target=arm-apple-darwin64" CC="""`xcode-select -p`"/usr/bin/gcc" --target=arm-apple-darwin64" --host=arm-apple-darwin64 --enable-fast-install --enable-shared=no --prefix=`pwd` --without-x --with-jpeg-include-dir={ROOT}/jpeg-9c/arm-apple-darwin64/include --with-jpeg-lib-dir={ROOT}/jpeg-9c/arm-apple-darwin64/lib
checking build system type... x86_64-apple-darwin19.4.0
--
--
    cd {ROOT}/tiff-4.0.10/x86_64-apple-darwin ; \
    ../configure CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --enable-fast-install --enable-shared=no --prefix=`pwd` --without-x --with-jpeg-include-dir={ROOT}/jpeg-9c/x86_64-apple-darwin/include --with-jpeg-lib-dir={ROOT}/jpeg-9c/x86_64-apple-darwin/lib
checking build system type... x86_64-apple-darwin19.4.0
--
--
cd {ROOT}/tiff-4.0.10/arm-apple-darwin64 ; \
    {XCODE_DEV}/usr/bin/make -sj8 && {XCODE_DEV}/usr/bin/make install
Making all in port
--
--
cd {ROOT}/tiff-4.0.10/x86_64-apple-darwin ; \
    {XCODE_DEV}/usr/bin/make -sj8 && {XCODE_DEV}/usr/bin/make install
Making all in port
--
--

  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
 10 12.3M   10 1338k    0     0  1084k      0  0:00:11  0:00:01  0:00:10 1083k
 11 12.3M   11 1479k    0     0   658k      0  0:00:19  0:00:02  0:00:17  658k
 14 12.3M   14 1792k    0     0   550k      0  0:00:22  0:00:03  0:00:19  550k
 17 12.3M   17 2213k    0     0   522k      0  0:00:24  0:00:04  0:00:20  521k
 24 12.3M   24 3127k    0     0   596k      0  0:00:21  0:00:05  0:00:16  641k
 36 12.3M   36 4627k    0     0   739k      0  0:00:17  0:00:06  0:00:11  655k
 55 12.3M   55 7024k    0     0   970k      0  0:00:12  0:00:07  0:00:05 1111k
 81 12.3M   81 10.0M    0     0  1246k      0  0:00:10  0:00:08  0:00:02 1701k
100 12.3M  100 12.3M    0     0  1368k      0  0:00:09  0:00:09 --:--:-- 2089k
cd {ROOT}/leptonica-1.78.0 && ./autogen.sh 2> /dev/null
libtoolize: putting auxiliary files in AC_CONFIG_AUX_DIR, 'config'.
--
--
    cd {ROOT}/leptonica-1.78.0/ios/arm-apple-darwin64 ; \
    ../../configure CXX="""`xcode-select -p`"/usr/bin/g++" --target=arm-apple-darwin64" CC="""`xcode-select -p`"/usr/bin/gcc" --target=arm-apple-darwin64" --host=arm-apple-darwin64 --prefix=`pwd` --enable-shared=no --disable-programs --with-zlib --with-libpng --with-jpeg --with-libtiff --without-giflib --without-libwebp
checking build system type... x86_64-apple-darwin19.4.0
--
--
    cd {ROOT}/leptonica-1.78.0/ios/x86_64-apple-darwin ; \
    ../../configure CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --prefix=`pwd` --enable-shared=no --disable-programs --with-zlib --with-libpng --with-jpeg --with-libtiff --without-giflib --without-libwebp
checking build system type... x86_64-apple-darwin19.4.0
--
--
cd {ROOT}/leptonica-1.78.0/ios/arm-apple-darwin64 ; \
    {XCODE_DEV}/usr/bin/make -sj8 && {XCODE_DEV}/usr/bin/make install
Making all in src
--
--
cd {ROOT}/leptonica-1.78.0/ios/x86_64-apple-darwin ; \
    {XCODE_DEV}/usr/bin/make -sj8 && {XCODE_DEV}/usr/bin/make install
Making all in src
--
--
{ROOT}/leptonica-1.78.0/ios/arm-apple-darwin64/include/leptonica/arrayaccess.h -> {ROOT}/ios/include/leptonica/arrayaccess.h
curl -LO https://github.com/tesseract-ocr/tesseract/archive/4.1.0.zip && unzip -a 4.1.0.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
--
--
  inflating: tesseract-4.1.0/appveyor.yml  [text]  
  inflating: tesseract-4.1.0/autogen.sh  [text]  
   creating: tesseract-4.1.0/cmake/
--
--
  inflating: tesseract-4.1.0/unittest/validator_test.cc  [text]  
cd {ROOT}/tesseract-4.1.0 && ./autogen.sh 2> /dev/null
Running aclocal
--
--

$ ./configure [--enable-debug] [...other options]
export LIBS="-lz -lpng -ljpeg -ltiff" ; \
--
--
    ln -s {ROOT}/leptonica-1.78.0/src/ leptonica ; \
    ../../configure CXX="""`xcode-select -p`"/usr/bin/g++" --target=arm-apple-darwin64" CC="""`xcode-select -p`"/usr/bin/gcc" --target=arm-apple-darwin64" --host=arm-apple-darwin64 --prefix=`pwd` --enable-shared=no --disable-graphics
checking whether the C++ compiler works... yes
--
--
    ln -s {ROOT}/leptonica-1.78.0/src/ leptonica ; \
    ../../configure CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --prefix=`pwd` --enable-shared=no --disable-graphics
checking whether the C++ compiler works... yes
--
--

cd {ROOT}/tesseract-4.1.0/ios/arm-apple-darwin64 && {XCODE_DEV}/usr/bin/make -sj8 && {XCODE_DEV}/usr/bin/make install
Making all in src/arch
--
--
make[4]: Nothing to be done for `install-data-am'.
cd {ROOT}/tesseract-4.1.0/ios/x86_64-apple-darwin && {XCODE_DEV}/usr/bin/make -sj8 && {XCODE_DEV}/usr/bin/make install
Making all in src/arch
--
--
{ROOT}/tesseract-4.1.0/ios/arm-apple-darwin64/include/tesseract/tesscallback.h -> {ROOT}/ios/include/tesseract/tesscallback.h
{XCODE_DEV}/usr/bin/make platform=macos
mkdir -p {ROOT}/macos/lib
--
--
    cd {ROOT}/leptonica-1.78.0/macos/x86_64-apple-darwin ; \
    ../../configure CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --prefix=`pwd` --enable-shared=no --disable-programs --with-zlib --with-libpng --with-jpeg --with-libtiff --without-giflib --without-libwebp
checking build system type... x86_64-apple-darwin19.4.0
--
--
cd {ROOT}/leptonica-1.78.0/macos/x86_64-apple-darwin ; \
    {XCODE_DEV}/usr/bin/make -sj8 && {XCODE_DEV}/usr/bin/make install
Making all in src
--
--
    ln -s {ROOT}/leptonica-1.78.0/src/ leptonica ; \
    ../../configure CXX="""`xcode-select -p`"/usr/bin/g++" --target=x86_64-apple-darwin" CC="""`xcode-select -p`"/usr/bin/gcc" --target=x86_64-apple-darwin" --host=x86_64-apple-darwin --prefix=`pwd` --enable-shared=no --disable-graphics
checking whether the C++ compiler works... yes
--
--

cd {ROOT}/tesseract-4.1.0/macos/x86_64-apple-darwin && {XCODE_DEV}/usr/bin/make -sj8 && {XCODE_DEV}/usr/bin/make install
Making all in src/arch
