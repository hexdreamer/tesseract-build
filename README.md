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

With everything looking like it was built and installed, we can quickly check Tesseract itself using the **tesseract** command-line (CL) program.  Let's run **Scripts/test_tesseract.sh**, which will download some trained data for horizontal and vertical Japanese scripts and then run OCR on these 2 images:

| ![hello horizontal](Notes/static/test_hello_hori.png) | ![hello vertical](Notes/static/test_hello_vert.png) |
|-------------------------------------------------------|-----------------------------------------------------|

```zsh
% ./Scripts/test_tesseract.sh
test horizontal: passed
test vertical: passed
```

The actual recognized text for the vertical test is:

```none
Hello

,世界

```

## Creating an Xcode project

1. **File** &rarr; **New Project**
1. I don't know what kind of application it should, so I just pick the first which also happens to seem the most generic
1. Only change **Product Name**
1. Create the project at the base of this entire project, `$PROJECTDIR`
1. We need a measure for getting the libraries properly added to the project.  I've cribbed this function from SwiftyTesseract:

    ```swift
    private func createPix(from image: UIImage) -> Pix {
        let data = image.pngData()!
        let rawPointer = (data as NSData).bytes
        let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)
        return pixReadMem(uint8Pointer, data.count)
    }
    ```

    I'm dropping this in **ContentView.swift**.
1. Save that file and I get my first error:

    ```Use of undeclared type 'Pix'```

1. To add the libraries we need 