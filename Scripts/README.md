# An introduction

Welcome to the heart of building Tesseract-OCR!  We're glad you're checking out our project and hope we can help you integrate multi-lingual OCR into your iOS/macOS app.

The most simple and most reliable thing you should be able to do is run **build_all.sh**  Located in `$SCRIPTSDIR/build`, this script arranges the sequence and orders the getting-and-installing of the build tools and libraries required to produce Tesseract-OCR.  And then it finally makes the drag-and-drop Tesseract library, and its dependent libraries, that you need for Xcode.

Inside **build_all.sh** you'll see:

1. an option for `clean-all` (delete installed products)
1. the steps to **build all**

Comments have been added to explain some ordering and dependencies.

The build environment is created in each **build_\<package\>.sh** script; any individual package script can be run by itself.  Each package script describes the flow of:

- download and extract
- preconfigure and configure
- make and install
- create the final `lipo`-ed library that Xcode will use (for the multi-architecture imaging libraries)

The imaging libraries can have many different compiler flags and configuration options.  For each package, these variables are defined in a separate **config-make-install_\<package\>.sh** script.  The script also works to build the same package for different combinations of architecture, platform, and target.

## Packages, dependencies, prerequisites

So what are all these packages for?

The GNU tools **autoconf**, **automake**, **pkg-config**, and **libtool** are prerequisites for running the **./autogen.sh** scripts for both **leptonica** and **tesseract**.

The image libraries **libjpeg**, **libpng**, and **libtiff**, and the **zlib** compression library, are all dependencies for **leptonica** and for **tesseract**.  Leptonica is also a dependency for **tesseract**.

## zsh

The scripts are written in the best zsh we know.  And, if you're curious, a StackOverflow perspective on popularity: [Bash vs. Zsh][2].

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
