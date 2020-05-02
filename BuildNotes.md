## Existing work
Here's the Makefile credited in SwiftyTesseract: https://github.com/gali8/Tesseract-OCR-iOS/blob/master/TesseractOCR/Makefile

It seems crazy to write it as a Makefile, but whatever. Try cribbing this for what we need.

## Understanding multi-arch binaries, and supported iOS architectures
From, [Actually it's not THAT uncommon for fat binaries to contain multiple architectur... | Hacker News][1]:
> Actually it's not THAT uncommon for fat binaries to contain multiple architectures. True, on today's macOS (and especially in the fall when 32bit support will be deprecated in 10.14), it looks like x86_64 rules supreme, but for a long while it was common to have combined i386 and x86_64 fat binaries, and before that, combined ppc and i386 binaries. Finally, it's not far-fetched to believe that in the medium near future, we'll need fat binaries with x86_64 and aarch64.
>
> Edit: actually, even in today's mostly-x86_64-only world, there are fat binaries in macOS, because there is a separate "x86_64h" architecture for "haswell and better". So even in a pure 64bit intel world, there's going to be fat binaries for a while. For example, "file /usr/lib/libobjc.dylib" shows three slices on macOS 10.13:
>
>| Library | Description |
|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| libobjc.dylib: | Mach-O universal binary with 3 architectures: [x86_64:Mach-O 64-bit dynamically linked shared library x86_64] [x86_64h] |
| libobjc.dylib (for architecture x86_64): | Mach-O 64-bit dynamically linked shared library x86_64 |
| libobjc.dylib (for architecture i386): | Mach-O dynamically linked shared library i386 |
| libobjc.dylib (for architecture x86_64h): | Mach-O 64-bit dynamically linked shared library x86_64h |
>
> On iOS, having a non-fat binary is almost the exception to the rule. For the longest time, it was common to have both armv6 and armv7 slices, and these days, armv7 and aarch64 slices. Granted, with iOS11 dropping armv[6|7] and apps starting to drop iOS10 support, we'll have a run with non-fat aarch64 binaries for a while. This is quite visible for compile times and compile errors during development! Also, for iOS, there's bitcode and app thinning which does mean end user devices are often served a single slice non-fat binary anyways.
>
> Vendors of closed source iOS libraries, such as the "Google maps for iOS" SDK, often ship fat binaries for the .dylibs containing both armv7, aarch64, i386 and/or x86_64. Why are Intel slices for iOS a thing? To be able to run your app and the library in the Xcode iOS simulator, which actually runs x86 code only. That's why it's not called an "emulator".
>
> The history of fat binaries in macOS goes all the way back to NeXTSTEP (of course, since macOS is basically a modern NeXTSTEP, with NSObject still showing off the legacy behind the curtain to new iOS developers) where even m68k was a common slice. [NeXTSTEP, Multi-Architecture ("Fat") Binaries][2] which at times even exploded to "Quad-fat binaries" containing slices for m68k, i386, pa-risc and sparc all together in one executable.

From, [Arm architecture | Wikipedia][5]:
> iOS supports ARMv8-A in iOS 7 and later on 64-bit Apple SoCs. iOS 11 and later only supports 64-bit ARM processors and applications.

> ARMv8-A (often called ARMv8[...]) represents a fundamental change to the ARM architecture. It adds an optional 64-bit architecture [...], named "AArch64", and the associated new "A64" instruction set. AArch64 provides user-space compatibility with ARMv7-A, the 32-bit architecture, therein referred to as "AArch32" and the old 32-bit instruction set, now named "A32"

## Build tools for macOS
### Xcode 11...
> * is available in the Mac App Store and includes SDKs for iOS 13, macOS Catalina 10.15... 
> * supports development for devices running iOS 13.1. 
> * supports on-device debugging for iOS 8 and later...
> * requires a Mac running macOS Mojave 10.14.4 or later.

### Problems you might run into with Pre-requisites
 * [Can't compile a C program on a Mac after upgrading to Catalina 10.15][3]
 * [Can't compile C program on a Mac after upgrade to Mojave][4]

[1]: https://news.ycombinator.com/item?id=17306454
[2]: https://en.wikipedia.org/wiki/Fat_binary#NeXTSTEP_Multi-Architecture_Binaries
[3]: https://stackoverflow.com/questions/58278260/cant-compile-a-c-program-on-a-mac-after-upgrading-to-catalina-10-15
[4]: https://stackoverflow.com/questions/52509602/cant-compile-c-program-on-a-mac-after-upgrade-to-mojave
[5]: https://en.wikipedia.org/wiki/ARM_architecture
