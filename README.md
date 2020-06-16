# Making an OCR app for iOS or macOS, from scratch

Welcome to our project on building and using Tesseract OCR in your Xcode projects.  We started this project with the very strong philosophy that it should be easy to learn how to build a C or C++ library from source and then build an app on top of that.

As the person tasked with creating this guide, I didn't know, and still don't know how to do a lot of what this guide requires.  C is familiar, but I don't know it.  I've used Xcode before, but that was like 10 years ago and I didn't have to deal with libraries, targets, and most of the details that go into making this project.  And if that sounds familiar and your unsure, it's our desire to show you how to move forward.

## Building from source

The final Tesseract OCR library that we're going to use depends on the Leptonica library to manage the common image file formats.  And Leptonica is built upon the individual libraries for the different image formats.  In building the image libraries, Leptonica, an then Tesseract, we found that some parts of those builds required additional tools like autoconf and automake, from GNU.  The final arrangement of the tools and libraries that we found looks like:

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

and that exact list is taken straight out of **Scripts/build/build_all.sh**.  Just calling that one script will produce all the files we need for Xcode.

For the libraries we are concerned about, we'll build them with the following 3 formats: **ios_arm64**, **ios_x86_64**, **macos_x86_64**.  During installation these three files are modified and result in one iOS lib, **libname.a**, and one macOS lib, **libname-macos.a**.

The build steps and these concepts are explained in more detail in [Building](Scripts/README.md#Building).

## Verifying Tesseract

With everything looking like it was built and installed, we can quickly check Tesseract itself using the **tesseract** command-line program.  First, we need to get some language training data.

1. Go to <https://github.com/tesseract-ocr/tessdata_best> and download **eng.traineddata**, **jpn.traineddata**, **jpn_vert.traineddata**.
1. The tesseract binary is located at $ROOT/macos_x86_64/bin, so download the traineddata files to $ROOT/macos_x86_64/share/tessdata.
1. We included a sample image that contains some very simply English and Japanese text
    ![Hello, world](hello-world.png)
1. The tesseract command takes a language (traineddata) name, the path to the image, and `stdout` to print to the shell

    ```zsh
    % cd to $ROOT/macos_x86_64/bin
    % ./tesseract -l eng ../../../hello-world.png stdout
    ```

    and you should see something like the following where the English text is perfectly recognized and the Japanese text is not recognized for the traineddata

    ```none
    Hello, th5¢
    ```

    Running almost the same command again, but this time for Japanese scripts

    ```zsh
    % ./tesseract -l jpn ../../../hello-world.png stdout

    Hello, 世界
    ```

    and the Japanese text is recognized, as well as the English text.

    Running the command again, but this time for *vertical* Japanese scripts

    ```zsh
    % ./tesseract -l jpn_vert ../../../hello-world.png stdout

    エのoo 店泡
    ```

    and nothing is accurately recognized.

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