# Multilingual OCR for your for iOS or macOS project

Welcome to our **Tesseract OCR in an Xcode** project.  We started this project with the very strong philosophy that it should be *easy* to see how a C or C++ library is built from source and then integrated into an app.

Like, this *easy*:

1. **git clone** or download this repo
1. **cd** to the repo
1. run **Scripts/build/build_all.sh**
1. wait for successful build
1. run **Scripts/test_tesseract.sh**: get some language recognition data and use it to test Tesseract against sample Chinese, English, and Japanese images
1. open **iOCR/iOCR.xcodeproj**
1. run the **iOCR** target on an iPad Pro 12.9-inch simulator

If you want to learn more about those steps, we've laid out the repo and included this guide to show how we:


- [Build from source](#build-from-source): create a build chain and organize the configurations for the various tools and libraries (packages) that make up Tesseract OCR
- [Test Tesseract](#test-tesseract): quickly and directly get to using Tesseract by running a small test, that also adds needs target language data
- [Write an app](#write-an-app): wrap the Leptonica and Tesseract C-API's into a very basic and static iPad app that shows some recognition features for traditional Chinese, English, and Japanese

## Build from source

The Tesseract OCR library manages its image data with Leptonica, a library that manipulates common image file formats.  And Leptonica is built upon the individual libraries for some of the different image formats it supports: jpg, png, tiff.

Completing the sequence of building the image libraries, Leptonica, and then Tesseract requires some additional tools, like autoconf and automake from GNU.

The final arrangement of the packages I settled on looks like:

1. autoconf
1. automake
1. pkgconfig
1. libtool
1. libjpeg
1. libpng
1. libtiff
1. leptonica
1. tesseract

### Starting the build

This guide refers to the project folder that you cloned or downloaded as **PROJECTDIR**.  For each of the packages above, the build process:

1. downloads a package's TGZ to **Downloads**
1. extracts that TGZ to **Sources**
1. configures and makes that source, then installs those build products into **Root**

The **Scripts/build** directory contains all the shell scripts to order and execute those steps.

```zsh
 % ls Scripts/build 
build_all.sh*                     build_tesseract.sh*
build_autoconf.sh*                build_zlib.sh*
build_automake.sh*                config-make-install_leptonica.sh
build_leptonica.sh*               config-make-install_libjpeg.sh
build_libjpeg.sh*                 config-make-install_libpng.sh
build_libpng.sh*                  config-make-install_libtiff.sh
build_libtiff.sh*                 config-make-install_tesseract.sh
build_libtool.sh*                 project_environment.sh
build_only_libs.sh*               utility.sh
build_pkgconfig.sh*
```

Any of the **build_\<PACKAGE-NAME\>.sh** scripts can be run by itself, but the final scripts for Leptonica and Tesseract depend on previous installations.  **build_all.sh** orders and executes all this for you; running that one script will produce all the files that we will eventually need for Xcode:

```zsh
 % ./Scripts/build/build_all.sh

...

...

======== tesseract-4.1.1 ========
Downloading... done.
Extracting... done.
Preconfiguring... done.
ios_arm64: configuring... done, making... done, installing... done.
ios_x86_64: configuring... done, making... done, installing... done.
macos_x86_64: configuring... done, making... done, installing... done.
ios: lipo... done.
macos: lipo... done.
```

The builds are targeted for two different processor *architectures*, **arm64** and **x86_64**.  There are also two different *platform* configurations, **ios** and **macos**.  This results in the following three files for every library, and each is needed for the stated uses:

| lib name                            | use                                |
|-------------------------------------|------------------------------------|
| `Root/ios_arm64/lib/libname.a`    | running in iOS                     |
| `Root/ios_x86_64/lib/libname.a`   | running in iOS Simulator, on a mac |
| `Root/macos_x86_64/lib/libname.a` | running on a mac                   |

Xcode's **lipo** tool can stitch files from different architectures together, but it cannot stitch the same architectures together.  This will finally leave us with a set of two binary files for each library, and installed to the common location **Root/lib**:

| lipo these formatted libs                                        | into this final lib            |
|--------------------------------------------------------------------|---------------------------|
| `Root/ios_arm64/lib/libname.a` <br/> `Root/ios_x86_64/lib/libname.a` | `Root/lib/libname.a`       |
| `Root/macos_x86_64/lib/libname.a`                                   | `Root/lib/libname-macos.a` |

## Test Tesseract

Having run **build_all.sh** and successfully built Tesseract we need to provide it with the reference data it will use to recognize the characters in the language we are interested in.

Run **Scripts/test_tesseract.sh** to download some trained data for traditional Chinese, English and Japanese scripts, and run a quick OCR test on these sample images:

<table>
<tr>
<td>
<img src="Notes/static/test_hello_hori.png"/>
</td>
<td>
<img height="300" src="Notes/static/test_hello_vert.png"/>
</td>
<td>
<img height="300" src="iOCR/iOCR/Assets.xcassets/chinese_traditional_vert.imageset/cropped.png"/>
</td>
<td>
<img height="300" src="iOCR/iOCR/Assets.xcassets/english_left_just_square.imageset/hexdreams.png"/>
</td>
</tr>
<tr><td>Japanese</td><td>Japanese (vert)</td><td>Chinese (trad, vert)</td><td>English</td></tr>
</table>

```zsh
% ./Scripts/test_tesseract.sh
# Checking for Trained Data Language Files
downloading chi_tra.traineddata...done
downloading chi_tra_vert.traineddata...done
downloading eng.traineddata...done
downloading jpn.traineddata...done
downloading jpn_vert.traineddata...done
# Recognizing Sample Images
testing Japanese...passed
testing Japanese (vert)...passed
testing Chinese (trad, vert)...passed
testing English...passed
```

The images for the Japanese test were chosen because some Japanese writing will include words borrowed from English, and it's noteworthy that some English is recognized when processing exclusively for Japanese.

And with that little test completed, we can get into Xcode.

## Write an app

If you're not familiar with the Tesseract C-API, here are the basics&mdash;that this project builds upon&mdash;with figurative code samples.

### Tesseract API basis

#### Initialize API object

Create an API object and initialize it with the trained data's parent folder, the data's filename, and an *OCR engine mode (OEM)*.  **OEM_LSTM_ONLY** is the latest neural-net recognition engine, which has some advantage in "line recognition" over the previous engine.

```swift
tessAPI = TessBaseAPICreate()
TessBaseAPIInit2(tessAPI, trainedDataFolder, "jpn_vert", OEM_LSTM_ONLY)
```

#### Perform OCR

Get an image and set it on the API, then configure the resolution and *page segmentation mode (PSM)*.  By default, Tesseract expects a page of text when it segments an image, and **PSM_AUTO** defines this default behavior.  All the images in this guide have been cropped to just the text, so this value makes sense for most of samples in this demo/guide.

```swift
image = getImage("japanese_vertical_sample")
TessBaseAPISetImage2(tessAPI, image)
TessBaseAPISetSourceResolution(tessAPI, 144)
TessBaseAPISetPageSegMode(tessAPI, PSM_AUTO)
```

Finally, call the method that returns the recognized text in the image.

```swift
TessBaseAPIGetUTF8Text(tessAPI)
```

We could stop here, but there's more we can know about the text.

#### Iterate over results

The API also provides an iterator for individually recognized objects in the image.  The size or scope of the object is determined by *level*.  **RIL_TEXTLINE** is the *ResultIteratorLevel* for working with individual lines of text.

```swift
level = RIL_TEXTLINE
iterator = TessBaseAPIGetIterator(tessAPI)

while (TessPageIteratorNext(iterator, level) > 0) {
  txt = TessResultIteratorGetUTF8Text(iterator, level)
  TessPageIteratorBoundingBox(iterator, level, &originX, &originY, &width, &height)
  confidence = TessResultIteratorConfidence(iterator, level)
}
```

*Note:* `TessBaseAPIGetUTF8Text` must be called before the `TessPageIterator` and `TessResultIterator` methods.

There is a small test and working example of these basics in **iOCRTests.swift::testGuideExample()** in the Xcode project.

### iOCR Xcode project

**PROJECTDIR/iOCR/iOCR.xcodeproj** is an example of putting everything together into a working project and running an app in the simulator that highlights those API basics.

Open the project and run the **iOCR** target for an **iPad Pro (12.9-in)**:

<img height="650" src="Notes/static/guide/ipad_app_blank_errors.png"/>

The colored rectangles, texts, and numbers are the iterated bounding boxes, utf8 texts, and confidence scores from the basics section and are now wrapped up in a **RecognizedRectangle**:

```swift
struct RecognizedRectangle {
    public var text: String
    public var boundingBox: CGRect
    public var confidence: Float
}
```

and this struct is handled with the **Recognizer** class which exposes two main methods for getting plain text or RecognizedRectangles:

```swift
let recognizer = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)


print recognizer.getAllText()

  (String) $R2 = "Hello\n\n,世界\n"


print recognizer.getRecognizedRects()

  ([iOCR.RecognizedRectangle]) $R8 = 2 values {
    [0] = {
      text = "Hello\n\n"
      boundingBox = (origin = (x = 9, y = 12), size = (width = 22, height = 166))
      confidence = 88.5363388
    }
    [1] = {
      text = ",世界\n"
      boundingBox = (origin = (x = 7, y = 210), size = (width = 30, height = 83))
      confidence = 78.3088684
    }
}
```

#### A weird rectangle and \<\*blank\*\>

In the Japanese sample images, we can see the text value `<*blank*>` with a confidence of 95.00%.  Those values correspond to the unexpected recognition of a single stroke inside the <span style="font-size: 1.25em">世</span> character as a whole other valid character, weird...

<img height="200" src="Notes/static/guide/blank_error_cropped.png"/>

but completely avoidable with only a little more understanding of the images.

The Japanese sample images were initially created for the demo like so:

```swift
var jpn = Recognizer(imgName: "japanese", trainedDataName: "jpn")
var jpn_vert = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert")
```

which uses a default DPI of 72.  These images have a DPI of 144, though.


#### Better configuration is better recognition

Simply add the correct DPI to the Recognizer:

```swift
var jpn = Recognizer(imgName: "japanese", trainedDataName: "jpn", imgDPI: 144)
var jpn_vert = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)
```

and it just works!

<img height="235" src="Notes/static/guide/ipad_app_fixed_cropped.png"/>

This little problem-and-solution set starts to highlight some of the internal workings of Tesseract.

#### Learning Tesseract

Configuration can matter a lot for Tesseract.  If you're new to it, you might need to dig in if you don't immediately get good results.  Here are two resources I've consulted:

- **Is there a Minimum / Maximum Text Size? (It won’t read screen text!)**  [https://tesseract-ocr.github.io/tessdoc/FAQ-Old#is-there-a-minimum--maximum-text-size-it-wont-read-screen-text]

- **Improving the quality of the output** [https://tesseract-ocr.github.io/tessdoc/ImproveQuality]
