# Miscellaneous

## Problem with -lrt lib in Tesseract make

Main problem is:

```none
warning: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ranlib: archive library: .libs/libtesseract_opencl.a the table of contents is empty (no object file members in the library define global symbols)
ld: library not found for -lrt
clang: error: linker command failed with exit code 1 (use -v to see invocation)
make[2]: *** [tesseract] Error 1
make[1]: *** [all-recursive] Error 1
make: *** [all] Error 2
```

This `-lrt` option is for an old library.  Searched online and the common solution for `ld: library not found for -lrt` and `clang: error: linker command failed with exit code 1 (use -v to see invocation)` is "take it out".

Trying to find where this option comes from in the config/make process:

```none
tesseract-4.1.1 % grep -r -- '-lrt' *
autom4te.cache/output.0:        LIBS="$LIBS -lsocket -lnsl -lrt -lxnet"
autom4te.cache/output.1:        LIBS="$LIBS -lsocket -lnsl -lrt -lxnet"
autom4te.cache/output.3:        LIBS="$LIBS -lsocket -lnsl -lrt -lxnet"
autom4te.cache/output.2:        LIBS="$LIBS -lsocket -lnsl -lrt -lxnet"
configure:        LIBS="$LIBS -lsocket -lnsl -lrt -lxnet"
configure.ac:        LIBS="$LIBS -lsocket -lnsl -lrt -lxnet"
ios_arm64/src/api/Makefile:am__append_12 = -lrt
src/api/Makefile.am:tesseract_LDADD += -lrt
src/api/Makefile.in:@ADD_RT_TRUE@am__append_12 = -lrt
```

```none
tesseract-4.1.1 % ll src/api/Makefile.*
-rw-r--r--  1 zyoung  staff   3.2K Dec 26  2019 src/api/Makefile.am
-rw-r--r--  1 zyoung  staff    46K Jan 12 12:23 src/api/Makefile.in
```

**Makefile.in** is derived from **Makefile.am**, so looking at the very last 3 lines in Makefile.am:

```none
tesseract-4.1.1 % tail -n3 src/api/Makefile.am
if ADD_RT
tesseract_LDADD += -lrt
endif
```

The solution ended up being to have **config.sub** spit out `arm-apple-darwin64`, that way the **configure** script would catch `*darwin*` as a host it expected and set the correct `ADD_RT_*` flags:

```sh
...
*darwin*)
  OPENCL_LIBS=""
  OPENCL_INC=""
  if false; then
    ADD_RT_TRUE=
    ADD_RT_FALSE='#'
  else
    ADD_RT_TRUE='#'
    ADD_RT_FALSE=
  fi
...
```

The `TARGET` parameter remains like `arm64-apple-iphoneos14.3`.

## Building on Apple Silicon

- Make four different os_platform-named libraries, just about how to make XCode use the "simulator" lib for running the Simulator
- Make 5 different products--iOS arm64, Sim arm64, Sim x86, macOS arm64, macOS x86--lipo'd into 3 libs--iOS, Sim, macOS.

- [iOS 14, lipo error while creating library for both device and simulator
](https://stackoverflow.com/questions/64022291/ios-14-lipo-error-while-creating-library-for-both-device-and-simulator)

  And the answer is to not include arm64 in the simulator library

- [How to build a static library on M1 mac that supports iOS simulator on Intel mac?](https://stackoverflow.com/questions/65564805/how-to-build-a-static-library-on-m1-mac-that-supports-ios-simulator-on-intel-mac)

  > It seems that I have to build a xcframework which contains binaries for different destinations.
  > So I tried to build different slices and hope to bundle them as a xcframework. But I finally found I don't know how to build the x86_64 slice with a M1 Mac.

- [](https://developer.apple.com/forums/thread/656509?answerId=634370022#634370022)

  > ```none
  > EXCLUDED_ARCHS[sdk=iphoneos*] = x86_64
  > EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64
  > ARCHS[sdk=iphoneos*] = arm64
  > ARCHS[sdk=iphonesimulator*] = x86_64
  > VALID_ARCHS[sdk=iphoneos*] = arm64
  > VALID_ARCHS[sdk=iphonesimulator*] = x86_64
  > ```
  >
  >  My specific build ***intel*** based macOS environment

Buiding XCode project ArchTest for Simulator:

```none
CompileSwift normal arm64 /Users/zyoung/develop/ArchTest/ArchTest/ArchTest.swift (in target 'ArchTest' from project 'ArchTest')
    cd /Users/zyoung/develop/ArchTest
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift -frontend -c -primary-file /Users/zyoung/develop/ArchTest/ArchTest/ArchTest.swift -emit-module-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/Objects-normal/arm64/ArchTest\~partial.swiftmodule -emit-module-doc-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/Objects-normal/arm64/ArchTest\~partial.swiftdoc -emit-module-source-info-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/Objects-normal/arm64/ArchTest\~partial.swiftsourceinfo -serialize-diagnostics-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/Objects-normal/arm64/ArchTest.dia -emit-dependencies-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/Objects-normal/arm64/ArchTest.d -emit-reference-dependencies-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/Objects-normal/arm64/ArchTest.swiftdeps -target arm64-apple-ios14.3-simulator -Xllvm -aarch64-use-tbi -enable-objc-interop -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator14.3.sdk -I /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Products/Debug-iphonesimulator -F /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Products/Debug-iphonesimulator -enable-testing -g -module-cache-path /Users/zyoung/build/ModuleCache.noindex -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -Xcc -working-directory -Xcc /Users/zyoung/develop/ArchTest -enable-anonymous-context-mangled-names -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/ArchTest-generated-files.hmap -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/ArchTest-own-target-headers.hmap -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/ArchTest-all-target-headers.hmap -Xcc -iquote -Xcc /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/ArchTest-project-headers.hmap -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Products/Debug-iphonesimulator/include -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/DerivedSources-normal/arm64 -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/DerivedSources/arm64 -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/DerivedSources -Xcc -DDEBUG\=1 -target-sdk-version 14.3 -parse-as-library -module-name ArchTest -o /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphonesimulator/ArchTest.build/Objects-normal/arm64/ArchTest.o -index-store-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Index/DataStore -index-system-modules
  ```
  
  Buiding XCode project ArchTest for Simulator:

  ```none
  CompileSwift normal arm64 /Users/zyoung/develop/ArchTest/ArchTest/ArchTest.swift (in target 'ArchTest' from project 'ArchTest')
    cd /Users/zyoung/develop/ArchTest
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift -frontend -c -primary-file /Users/zyoung/develop/ArchTest/ArchTest/ArchTest.swift -emit-module-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/Objects-normal/arm64/ArchTest\~partial.swiftmodule -emit-module-doc-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/Objects-normal/arm64/ArchTest\~partial.swiftdoc -emit-module-source-info-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/Objects-normal/arm64/ArchTest\~partial.swiftsourceinfo -serialize-diagnostics-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/Objects-normal/arm64/ArchTest.dia -emit-dependencies-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/Objects-normal/arm64/ArchTest.d -emit-reference-dependencies-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/Objects-normal/arm64/ArchTest.swiftdeps -target arm64-apple-ios14.3 -Xllvm -aarch64-use-tbi -enable-objc-interop -stack-check -sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.3.sdk -I /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Products/Debug-iphoneos -F /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Products/Debug-iphoneos -enable-testing -g -module-cache-path /Users/zyoung/build/ModuleCache.noindex -swift-version 5 -enforce-exclusivity\=checked -Onone -D DEBUG -serialize-debugging-options -Xcc -working-directory -Xcc /Users/zyoung/develop/ArchTest -enable-anonymous-context-mangled-names -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/swift-overrides.hmap -Xcc -iquote -Xcc /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/ArchTest-generated-files.hmap -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/ArchTest-own-target-headers.hmap -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/ArchTest-all-target-headers.hmap -Xcc -iquote -Xcc /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/ArchTest-project-headers.hmap -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Products/Debug-iphoneos/include -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/DerivedSources-normal/arm64 -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/DerivedSources/arm64 -Xcc -I/Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/DerivedSources -Xcc -DDEBUG\=1 -target-sdk-version 14.3 -parse-as-library -module-name ArchTest -o /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Build/Intermediates.noindex/ArchTest.build/Debug-iphoneos/ArchTest.build/Objects-normal/arm64/ArchTest.o -embed-bitcode-marker -index-store-path /Users/zyoung/build/ArchTest-ejeyjimwgatdsjbppaofjbvsggtj/Index/DataStore -index-system-modules
  ```

## Tesseract Version / Source

Not the clearest to find, but we're using 4.1.1, and [the manual](https://tesseract-ocr.github.io/tessdoc/) has a link to the TARGZ file.

## libtiff header

**tiffconf.h** has one value with two different definitions between **arm64** and **x86_64**, and might affect you if you are building for macOS.

```sh
% diff -r Root/ios_arm64/include Root/macos_x86_64/include
diff -r Root/ios_arm64/include/tiffconf.h Root/macos_x86_64/include/tiffconf.h
48c48
< #define HOST_FILLORDER FILLORDER_MSB2LSB
---
> #define HOST_FILLORDER FILLORDER_LSB2MSB
```

From, <https://www.awaresystems.be/imaging/tiff/tifftags/fillorder.html>:

> LibTiff defines these values:
>
> FILLORDER_MSB2LSB = 1;
> FILLORDER_LSB2MSB = 2;
>
> In practice, the use of FillOrder=2 is very uncommon, and is not recommended.

From, <http://www.libtiff.org/internals.html>:

> Native CPU byte order is determined on the fly by the library and does not need to be specified. The HOST_FILLORDER and HOST_BIGENDIAN definitions are not currently used, but may be employed by codecs for optimization purposes.

As **ios_arm64** seems the more important library, by default those headers will be used.

*If you are making a macOS app and have problems linking/referencing the API, consider adjusting this final copy.*

## Troubleshooting

The errors coming out of the configure step can be difficult to understand if you only read the **Step#_config.err** in the **Logs** directory.

The key to debugging configure errors is to check the **config.log** for a given build in that build's **Sources** directory.

Given this error running build_all.sh:

```none
macos_x86_64: configuring... ERROR running ../configure CC=...
...
...
ERROR see ~/$PROJECTDIR/Logs/tesseract-4.1.1/3_config_macos_x86_64.err for more details
```

Looking at **Logs/tesseract-4.1.1/3_config_macos_x86_64.err**:

```none
configure: error: in `~/$PROJECTDIR/Sources/tesseract-4.1.1/macos_x86_64':
configure: error: C++ compiler cannot create executables
See `config.log' for more details
```

The last line, *See `config.log' for more details* is the true clue.

Here's the telling error message from **Sources/tesseract-4.1.1/macos_x86_64/config.log**:

```none
...
ld: library not found for -lpng
clang: error: linker command failed with exit code 1 (use -v to see invocation)
...
```

In this case, I had just clobbered all macos_x86_64 binaries/libraries including **macos_x86_64/lib/libpng16.a**.  And this is what `./configure` failed on.

Other "errors" like the following may not really be errors, it's just configure trying out different configurations:

```none
configure:2663: /Applications/Xcode.app/Contents/Developer/usr/bin/g++ -V >&5
clang: error: unsupported option '-V -Wno-objc-signed-char-bool-implicit-int-conversion'
clang: error: no input files
```

and:

```none
configure:2663: /Applications/Xcode.app/Contents/Developer/usr/bin/g++ -qversion >&5
clang: error: unknown argument '-qversion'; did you mean '--version'?
clang: error: no input files
```
