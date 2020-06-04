# An introduction

Welcome to the heart of building Tesseract-OCR!  We're glad you're checking out our project and hope we can help you integrate multi-lingual OCR into your iOS/macOS app.

The most simple and most reliable thing you should be able to do is run **build_all.sh**  Located in `$SCRIPTSDIR/build`, this script arranges the sequence and orders the getting-and-installing of the build tools and libraries required to produce Tesseract-OCR.  And then it finally makes the drag-and-drop Tesseract library, and its dependent libraries, that you need for Xcode.

## Building

Looking inside the build directory, you'll see build_all.sh, a number of package scripts for building and configuration, and project_environment.sh, like:

```zsh
build_all.sh
build_autoconf.sh
...
build_tesseract.sh
...
config-make-install_tesseract.sh
...
project_environment.sh
```

Inside build_all.sh are:

1. an option to **clean-all** (delete installed products)
1. all the packages/libraries in a build order that is correct

Inside each **build_\<package\>.sh** script is the sequence of events for getting, building, and installing that package:

1. download and extract
1. preconfigure and configure
1. make and install
1. create the final `lipo`-ed library that Xcode will use (for the multi-architecture imaging libraries) and copy over included header files

The imaging libraries can have many different compiler flags and configuration options.  These variables are defined in a separate **config-make-install_\<package\>.sh** script.  The script also works to build the same package for different combinations of architecture, platform, and target and is called repeatedly from its build_\<package\>.sh script.

The build environment is created in each build_\<package\>.sh and config-make-install_\<package\>.sh script by sourcing **project_environment.sh**.

## Installing

The image libraries are configured to install their products in $ROOT, grouped into the three *platform architectures*: **ios_arm64**, **ios_x86_64**, **macos_x86_64**.  For some of the key components of the tesseract build, it would look like this on disc:

```zsh
Root
├── ios_arm64
│   ├── include
│   │   └── tesseract
│   │       └── capi.h
│   └── lib
│       └── tesseract.a
├── ios_x86_64
│   ├── include...
│   └── lib
│       └── tesseract.a
└── macos_x86_64
    ├── include...
    └── lib
        └── tesseract.a
```

From this structure:

1. **ios** binaries are lipoed together into a multi-arch binary, while the **macos** binary is just renamed, like:

    ```zsh
    lipo Root/ios_arm64/lib/tesseract.a Root/ios_x86_64/lib/tesseract.a -create -output Root/lib/tesserarct.a
    lipo Root/macos_x86_64/lib/tesseract.a -create -output Root/lib/tesserarct-macos.a
    ```

1. the header files are copied from ios_arm64

    ```zsh
    xc mkdir -p Root/include/tesseract
    cp Root/ios_arm64/tesseract/* Root/include/tesseract
    ```

and the final Xcode-ready structure is complete:

```zsh
Root
├── include
│   └── tesseract
│       └── capi.h
└── lib
    ├── tesseract-macos.a
    └── tesseract.a
```

### libtiff header

**tiffconf.h** one value with two different definitions between **arm64** and **x86_64**:

```zsh
% diff -r Root/ios_arm64/include Root/macos_x86_64/include
diff -r Root/ios_arm64/include/tiffconf.h Root/macos_x86_64/include/tiffconf.h
48c48
< #define HOST_FILLORDER FILLORDER_MSB2LSB
---
> #define HOST_FILLORDER FILLORDER_LSB2MSB
```

as **ios_x86_64** and **macos_x86_64** are identical:

```zsh
% diff -r Root/ios_x86_64/include Root/macos_x86_64/include
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

As **ios_arm64** seems the more important library, by default those headers will be used.  If you are making a macOS app and have problems linking/referencing the API, consider adjusting this final copy.

## Packages, dependencies, prerequisites

So what are all these packages for?

The GNU tools **autoconf**, **automake**, **pkg-config**, and **libtool** are prerequisites for running the **./autogen.sh** scripts for both **leptonica** and **tesseract**.

The image libraries **libjpeg**, **libpng**, and **libtiff**, and the **zlib** compression library, are all dependencies for **leptonica** and for **tesseract**.  Leptonica is also a dependency for **tesseract**.

## zsh

The scripts are written in the best zsh I know.  I set upon writing these scripts in zsh after years of getting by with bash.  To shore up my lack of knowledge around shell scripting, I started using Shellcheck in bash-mode on the zsh scripts for any insight into better coding practices and new concepts.  Trying to embrace the zsh-y way, I've started disabling some checks where I've seen clear examples from the author of zsh on how zsh does something differently than bash.

### Considerations for Shell Script style

- <https://google.github.io/styleguide/shellguide.html>
- <http://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/>
- <https://wiki.ubuntu.com/DashAsBinSh>

### Wrapping my head around word splitting

<https://unix.stackexchange.com/a/26672/366399>

> Zsh had arrays from the start, and its author opted for a saner language design at the expense of backward compatibility. In zsh (under the default expansion rules) $var does not perfom word splitting; if you want to store a list of words in a variable, you are meant to use an array; and if you really want word splitting, you can write $=var.
>
> ```zsh
> files=(foo bar qux)
> myprogram $files
> ```

<http://zsh.sourceforge.net/FAQ/zshfaq03.html>

> ...
> after which $words is an array with the words of $sentence (note characters special to the shell, such as the ' in this example, must already be quoted), or, less standard but more reliable, turning on SH_WORD_SPLIT for one variable only:
>
> ```zsh
> args ${=sentence}
> ```

[2]: https://insights.stackoverflow.com/trends?tags=bash%2Czsh
