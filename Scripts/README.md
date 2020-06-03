# An introduction

Welcome to the heart of building Tesseract-OCR!  We're glad you're checking out our project and hope we can help you integrate multi-lingual OCR into your iOS/macOS app.

The most simple and most reliable thing you should be able to do is run **build_all.sh**  Located in `$SCRIPTSDIR/build`, this script arranges the sequence and orders the getting-and-installing of the build tools and libraries required to produce Tesseract-OCR.  And then it finally makes the drag-and-drop Tesseract library, and its dependent libraries, that you need for Xcode.

## build_all

Inside **build_all.sh** you'll see:

1. an option for `clean-all` (delete installed products)
1. all the packages/libraries and the order of the build sequence

Comments have been added to explain some ordering and dependencies.

The build environment is created in each **build_\<package\>.sh** script; any individual package script can be run by itself.  Each package script describes the flow of:

- download and extract
- preconfigure and configure
- make and install
- create the final `lipo`-ed library that Xcode will use (for the multi-architecture imaging libraries)

The imaging libraries can have many different compiler flags and configuration options.  For each package, these variables are defined in a separate **config-make-install_\<package\>.sh** script.  The script also works to build the same package for different combinations of architecture, platform, and target and is called repeatedly from its **build_\<package\>.sh** script.  It looks something like this in practice:

```zsh
build_all.sh

  build_autoconf.sh
    project_environment.sh
      utility.sh

  build_tesseract.sh
    project_environment.sh
      utility.sh
    config-make-install_tesseract.sh
      project_environment.sh
        utility.sh
```

The last line in that example, `lipo macos...`, hints at the arrangement of files when a build is done.  The build products for the libraries end up in `$ROOT` grouped by the three *platform architectures*, **ios_arm64**, **ios_x86_64**, and **macos_x86_64**, like:

```zsh
Root/
  ios_arm64/
    include/
      tesseract/
        capi.h
    lib/
      tesseract.a
  ios_x86_64/
    lib/
      tesseract.a
  macos_x86_64/
    lib/
      tesseract.a
```

**ios** binaries are lipoed together into a multi-arch binary, while the **macos** binary is just renamed, like:

```zsh
lipo Root/ios_arm64/lib/tesseract.a Root/ios_x86_64/lib/tesseract.a -create -output Root/lib/tesserarct.a
lipo Root/macos_x86_64/lib/tesseract.a -create -output Root/lib/tesserarct-macos.a
```

Header files are also copied into the final structure:

```zsh
xc mkdir -p Root/include/tesseract
cp Root/ios_arm64/tesseract/* Root/include/tesseract
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
