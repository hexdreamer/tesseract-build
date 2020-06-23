## Troubleshooting

```zsh
macos_x86_64: configuring... ERROR running ../configure CC=...
...
...
ERROR see /Users/zyoung/dev/tesseract-build/Logs/tesseract-4.1.1/3_config_macos_x86_64.err for more details
```

Looking at **Logs/tesseract-4.1.1/3_config_macos_x86_64.err**:

```none
configure: error: in `/Users/zyoung/dev/tesseract-build/Sources/tesseract-4.1.1/macos_x86_64':
configure: error: C++ compiler cannot create executables
See `config.log' for more details
```

And even though it's not mentioned, I've learned to check all available logs because *sometimes* the relevant info can be found outside of the ERR file.

Looking at **Logs/tesseract-4.1.1/3_config_macos_x86_64.out**:

```none
checking whether the C++ compiler works... no
```

Wow, looks like there could be a really big problem here, since the error indicates the issue is with the compiler directly.  In this case, looking at the OUT file might leave you really alarmed and confused.  I think part of being a good detective is understanding the significance of the clues.  While this message is very unambiguous, "the compiler doesn't work", but it doesn't provide any details that allow us to further investigate "the C++ compiler".

I already know the true error to this problem and it's isn't the compiler.  Here's the telling error message from **Sources/tesseract-4.1.1/macos_x86_64/config.log**:

```none
...
ld: library not found for -lpng
clang: error: linker command failed with exit code 1 (use -v to see invocation)
...
```

It's true that Tesseract couldn't be compiled, but that's because I just destroyed *all* macos_x86_64 binaries/libraries including **macos_x86_64/lib/libpng16.a** which is what `./configure` failed on.  And keep in mind that this true error came just after other "errors" like:

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

which is simply `./configure` trying a number of different options to prove the version of the compiler.  So, troubleshooting will require some familiarization with this system.

# Making an OCR app for iOS or macOS, from scratch

Welcome to our project on building and using Tesseract OCR in your Xcode projects.  We started this project with the very strong philosophy that it should be easy to learn how to build a C or C++ library from source and then build an app on top of that.

As the person tasked with creating this guide, I didn't know, and still don't know how to do a lot of what this guide requires.  C is familiar, but I don't know it.  I've used Xcode before, but that was like 10 years ago and I didn't have to deal with libraries, targets, and most of the details that go into making this project.  And if that sounds familiar and your unsure, hopefully this can guide you forward.

## Building from source

The final Tesseract OCR library that we're going to use depends on the Leptonica library to manage the common image file formats.  And Leptonica is built upon the individual libraries for the different image formats.  In building the image libraries, Leptonica, and then Tesseract, we found that some parts of those builds required additional tools like autoconf and automake, from GNU.  The final arrangement of the tools and libraries that we found looks like:

1. autoconf
1. automake
1. pkgconfig
1. libtool
1. zlib
1. libjpeg
1. libpng
1. libtiff
1. leptonica
1. tesseract

and that exact list is taken straight out of **Scripts/build/build_all.sh**.  Just running that one script will produce all the files we need for Xcode.

The build products that can be used by Xcode will have the following 3 formats: **ios_arm64**, **ios_x86_64**, **macos_x86_64**.  We stitch the two-iOS formatted files into one multi-arch binary, **libname.a**. We write the one macOS-formatted file to a single-arch binary, **libname-macos.a**.

| xcode-lipo these formatted libs                                        | into this final lib            |
|--------------------------------------------------------------------|---------------------------|
| `$ROOT/ios_arm64/lib/libname.a` <br/> `$ROOT/ios_x86_64/lib/libname.a` | `$ROOT/lib/libname.a`       |
| `$ROOT/macos_x86_64/lib/libname.a`                                   | `$ROOT/lib/libname-macos.a` |

The build steps and these concepts are explained in more detail in [Building](Scripts/README.md#Building).

## Verifying Tesseract

Now that we have built Tesseract, we need to provide it with the reference data it will use to recognize the characters in the language we are interesed in.

Run **Scripts/test_tesseract.sh** to download some trained data for horizontal and vertical Japanese scripts and run OCR on these 2 images:

| ![hello horizontal](Notes/static/test_hello_hori.png) | ![hello vertical](Notes/static/test_hello_vert.png) |
|-------------------------------------------------------|-----------------------------------------------------|

```zsh
% ./Scripts/test_tesseract.sh
test horizontal: passed
test vertical: passed
```

The actual text recognized in the vertical image is:

```none
Hello

,世界

```

but for this simple test, all white space is stripped out and the result is compared to `'Hello,世界'`.

These images were chosen because some Japanese writing will include English loan words and I think it's noteworthy that some English is recognized when processing exclusively for Japanese.

And with that little test completed, we can get into Xcode.

## Integrating Tesseract into Xcode

As a personal aside, I don't have much experience with C or Swift.  I've gotten us this far with some personal experience with shell scripts and build systems, but much of the insight into configurating and executing the build came from the Makefile of another open-source iOS Tesseract project, SwiftyTesseract (ST).  I'm going to create a new Xcode project and insert a bit of isolated code from ST, which will immediately fail to build.  I'll chase down build errors as they come, modifying the project along the way.

1. **File** &rarr; **New Project**

1. A **Single View App** is a great template for this guide, **Next**

1. Add **Product Name**, I've named mine *iOCR*

1. Create the project at the base of this entire project, `$PROJECTDIR`

1. **File** &rarr; **New** &rarr; **File...**

1. Choose **Swift File**, **Next**

1. **Save As:** **iOCR**, leave all else as default, **Create**

1. Find the file at top of the tree in the Project Navigator, and move the file down under the **iOCR** folder.  My project now looks like this:

    ![iOCR.swift in iOCR folder](Notes/static/guide_project_navigator_dark.png)

1. Insert this snippet into **iOCR.swift**:

    ```swift
    import libtesseract
    import libleptonica
    ```

1. Save that file, and my first error is:

    ```none
    No such module 'libtesseract'
    ```

    Our newly built libs need to be brought into Xcode as modules.

    1. Copy the build products into the new Xcode project folder:

        ```zsh
        ditto $ROOT/include iOCR/iOCR/dependencies/include
        ditto $ROOT/lib iOCR/iOCR/dependencies/lib
        ditto $ROOT/share/tessdata iOCR/iOCR/dependencies/share/tessdata
        ```
    
    1. Right-click the iOCR folder in the project navigator and choose **Add Files to "iOCR"**:

        ![Add dependencies to iOCR folder](Notes/static/guide_add_dependencies.png)

    1. Select the **dependencies** folder, and leave **Create folder references** selected, **Add**

    1. **File &rarr; New...**, scroll down to **Other** and choose **Empty**, **iOCR/iOCR/dependencies/module.modulemap** with the following contents:

        ```swift
        module libtesseract {
            header "tesseract/capi.h"
            export *
        }

        module libleptonica {
            header "leptonica/allheaders.h"
            export *
        }
        ```

    1. My project now looks like:

        ![Final structure](Notes/static/guide_final_structure.png)

    1. Set the **SWIFT_INCLUDE_PATH** in the project's build settings:

