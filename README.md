<!-- markdownlint-disable-file MD033 -->
# Multilingual OCR for Swift and your iOS/macOS project

Welcome to our project, **Tesseract OCR in your Xcode Project**.  This will guide you through the process of building the Tesseract OCR library and using its API from Swift in your Xcode project, easily.

Like, this *easy*:

1. **git clone** or download this repo
1. **cd** to the repo
1. run **./Scripts/build/build_all.sh**
    1. wait for successful build
1. run **./Scripts/test_tesseract.sh**, to get some language recognition data and test the build
1. open **iOCR/iOCR.xcodeproj**
1. run the **iOCR** target on an iPad Pro 12.9-inch simulator

If you want to learn more about those steps, check out this guide and...

- [Learn about your environment](#the-project-environment): get to know this repo's layout
- [Build from source](#build-from-source): understand the arrangement of the libraries that make up Tesseract OCR; create a build chain; configure and build!
- [Test Tesseract](#test-tesseract): quickly and directly get to using Tesseract by running a small test; also get target language recognition data
- [Write an app](#write-an-app): wrap the Leptonica and Tesseract C-API's in Swift and make a **very basic** iPad app that shows some recognition features for traditional Chinese, English, and Japanese

## The project environment

This guide refers to the project folder that you cloned/downloaded as **PROJECTDIR**.  All command-line work, paths, and examples are from this base directory.

The new repo looks pretty bare:

```sh
% ls *
README.md

Notes:
static/

Root:
README.md  include/

Scripts:
README.md          build/             test_tesseract.sh*

iOCR:
iOCR/           iOCR.xcodeproj/ iOCRTests/
```

- All build products will be installed in **Root**; the **include** directory already has a modulemap file for our basic Xcode project
- The build scripts are in **Scripts/build**; **test_tesseract.sh** will be covered later in this guide
- **iOCR** is our basic Xcode project in Swift
- **Notes** contains some static images for the READMEs

The build scripts will also create new directories&mdash;**Downloads**, **Logs**, **Sources**&mdash;that will be populated with artifacts of the build process.

Let's move on to what we're building, and how it goes together.

## Build from source

The *top-level libraries* needed to perform OCR are, in hierarchical order:

- **tesseract**: the main library for performing OCR
  - **leptonica**: a library for managing image data and image manipulation
    - **libjpeg**, **libpng**, **libtiff**: the libraries for the individual image formats

There is additional tooling to support the process of building the top-level libs, packages like **autoconf** and **automake** from GNU.

The final arrangement of the packages we settled on looks like:

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

For each of the packages above, the build process:

1. downloads a package's TGZ/ZIP to Downloads
1. extracts that TGZ/ZIP to Sources
1. configures and makes that source, then installs those build products into Root

The **Scripts/build** directory contains all the shell scripts to execute those three steps.  Looking in there:

```sh
 % ls Scripts/build
build_all.sh*
...
build_leptonica.sh*
build_tesseract.sh*  
...
config-make-install_leptonica.sh
config-make-install_tesseract.sh
...
project_environment.sh
utility.sh
```

Any of the **build_PACKAGE-NAME.sh** scripts can be run by itself.  The top-level libraries also have a **config-make-install** helper script that covers the details of building and installing for multiple architectures and platforms, which we'll cover after we see the completed build.

**build_all.sh** is the build chain; running this one script will produce all the files that we will need for Xcode:

```sh
 % ./Scripts/build/build_all.sh

...
(some time later)
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

After a while, we see that Tesseract was finally configured, made, and installed.  And then there was a final **lipo** step.

The builds are targeted for two different processor *architectures*, **arm64** and **x86_64**.  There are also two different *platform* configurations, **ios** and **macos**.  This results in the following three files for every library, and each is needed for the following use-case:

| lib name                               | use                                |
|----------------------------------------|------------------------------------|
| `Root/ios_arm64/lib/libtesseract.a`    | running on an iOS device           |
| `Root/ios_x86_64/lib/libtesseract.a`   | running in iOS Simulator, on a Mac |
| `Root/macos_x86_64/lib/libtesseract.a` | running on a Mac (AppKit)          |

For iOS, we can use the lipo tool to stitch the files for the two different architectures together, and then we can plug that one lib into Xcode.  But, lipo cannot cannot stitch the same architectures together: the macos_x86_64 lib was built for the macOS platform, but its x86_64 architecture is the same as in the ios_x86_64 lib, so the macos_x86_64 lib is left as a separate file.  This will finally leave us with a set of two binary files for each library, and installed to the common location **Root/lib**:

| lipo these architecture_platform libs                                        | into this final lib             |
|------------------------------------------------------------------------------|---------------------------------|
| `Root/ios_arm64/lib/libtesseract.a`<br/>`Root/ios_x86_64/lib/libtesseract.a` | `Root/lib/libtesseract.a`       |
| `Root/macos_x86_64/lib/libtesseract.a`                                       | `Root/lib/libtesseract-macos.a` |

Now that Tesseract is built and installed, we can test it out and see our first payoff.

## Test Tesseract

To get a very quick and basic validation of our hard work, we'll ignore those installed libs for a moment and focus on a command-line (CL) tesseract program that was also built and installed as a part of our process.

For the CL (and lib-based Xcode) Tesseract to work, we need to get the *trained data* for the languages we want recognized.  We'll get Traditional Chinese and Japanese, both for vertical scripts, and English and Japanese, for horizontal.  The data is downloaded to **Root/share/tessdata**.  For this test, the data is made known to the CL tesseract program by exporting an environment variable, `export TESSDATA_PREFIX=$ROOT/share/tessdata`, in the test script.

Run **Scripts/test_tesseract.sh** to download the trained data and run a quick OCR test on these sample images:

<table>
<tr>
<td>
<img width="300" src="iOCR/iOCR/Assets.xcassets/japanese.imageset/test_hello_hori.png "/>
</td>
<td>
<img height="300" src="iOCR/iOCR/Assets.xcassets/japanese_vert.imageset/test_hello_vert.png"/>
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

```sh
% ./Scripts/test_tesseract.sh
# Checking for trained data language files...
downloading chi_tra.traineddata...done
downloading chi_tra_vert.traineddata...done
downloading eng.traineddata...done
downloading jpn.traineddata...done
downloading jpn_vert.traineddata...done
# Recognizing sample images...
testing Japanese...passed
testing Japanese (vert)...passed
testing Chinese (trad, vert)...passed
testing English...passed
```

And with that little test completed, we can get into Xcode.

## Write an app

The main API for Tesseract is in C++, but Swift doesn't support C++.  Swift does support C APIs, and Tesseract also has a C-API, so we'll use that. 

If you're not familiar with the Tesseract API, here are the basics with figurative code samples.

### Tesseract API basics, in Swift

The following Swift excerpts were taken from **testGuideExample()** in **iOCR/iOCRTests/iOCRTests.swift**.  We'll also ignore the destroy/teardown code.

#### Initialize API handler

Create an API handler and initialize it with the trained data's parent folder, the data's filename, and an *OCR engine mode (OEM)*.  **OEM_LSTM_ONLY** is the latest neural-net recognition engine, which has some advantage in text-line recognition over the previous engine.

```swift
let tessAPI = TessBaseAPICreate()!
TessBaseAPIInit2(tessAPI, trainedDataFolder, "jpn_vert", OEM_LSTM_ONLY)
```

**TessBaseAPIInit2()** is one of 4 API initializers, and lets us set the OEM.

#### Prepare the image

Tesseract uses Leptonica's **PIX** image format, so we need to get a pointer to a byte string of some UIImage data and pass the pointer to **pixReadMem()**:

```swift
let uiImage = UIImage(named: "japanese_vert")!
let data = uiImage.pngData()!
let rawPointer = (data as NSData).bytes
let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)

var image = pixReadMem(uint8Pointer, data.count)
```

#### Image settings & Perform OCR

Set our image, the resolution, and *page segmentation mode (PSM)*.  PSM defines how Tesseract sees or treats the image, like 'Assume a single column of text of variable sizes' or 'Treat the image as a single word'.  All the images in this guide have been cropped to just the text, and letting Tesseract figure this out for itself (**PSM_AUTO**) works just fine.

```swift
TessBaseAPISetImage2(tessAPI, image)
TessBaseAPISetSourceResolution(tessAPI, 144)
TessBaseAPISetPageSegMode(tessAPI, PSM_AUTO)
```

Finally, we call the **GetUTF8Text** method which runs the recognize functions inside Tesseract, and get some text back:

```swift
let txt = TessBaseAPIGetUTF8Text(tessAPI)
```

and looking at the result in the debugger:

```none
print String(cString: txt!)

  (String) $R3 = "Hello\n\n,世界\n"
```

We could stop here, but there's more we can know about the text.

#### Iterate over results

The API can recognizes varying *levels* of text in this top-down order: blocks, paragraphs, lines, words, symbols.  **RIL_TEXTLINE** is the *ResultIteratorLevel* for working with individual lines of text.  Here we're using a textline iterator and getting the (x1,y1) and (x2,y2) coordinates of the recognized line's bounding box:

```swift
let iterator = TessBaseAPIGetIterator(tessAPI)
let level = RIL_TEXTLINE

var x1: Int32 = 0
var y1: Int32 = 0
var x2: Int32 = 0
var y2: Int32 = 0

TessPageIteratorBoundingBox(iterator, level, &x1, &y1, &x2, &y2)
```

*Note:* `TessBaseAPIGetUTF8Text()` or `TessBaseApiRecognize()` must be called ***before*** the `TessPageIterator` and `TessResultIterator` methods.

There is a small test and working example of these basics in **iOCRTests.swift::testGuideExample()**, the following Xcode project.

### iOCR Xcode project

**PROJECTDIR/iOCR/iOCR.xcodeproj** is an example of putting everything together into a working project and running an app in the simulator that shows off those API basics.

Open the project and run the **iOCR** target for an **iPad Pro (12.9-in)**.

<img height="683" src="Notes/static/guide/ipad_app_all_good.png"/>

All four sample images were run through Tesseract at the **TEXTLINE** level.  We can also see between horizontal and vertical Japanese, and vertical Chinese, that the results of a "line" vary depending on some combination of language and the text's orientation; specifically <span style="font-size: 1.1em">Hello</span> and <span style="font-size: 1.1em">,世界</span> being recognized as two separate lines.

Each card consists of a sample image against a gray background.  Colored rectangles drawn on top of the image represent lines that Tesseract recognized.  Each recognized line is also represented in the table below the image.  The recognized line's bounding box, utf8 text, and confidence score are wrapped up in a **RecognizedRectangle**:

```swift
struct RecognizedRectangle: Equatable {
    let id = UUID()
    public var text: String
    public var boundingBox: CGRect
    public var confidence: Float
}
```

The **Recognizer** class manages that struct, along with all the API setup and teardown.  It has two main methods, `getAllText()` and `getRecognizedRects()`, for getting all text and/or RecognizedRectangles.  We'll create a recognizer:

```swift
let recognizer = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)
```

and, to simply show the results, call these methods in the debugger:

```none
print recognizer.getAllText()

  (String) $R2 = "Hello\n\n,世界\n"

// and...

print recognizer.getRecognizedRects()

  ([iOCR.RecognizedRectangle]) $R8 = 2 values {
    [0] = {
      id = {}
      text = "Hello\n\n"
      boundingBox = (origin = (x = 9, y = 12), size = (width = 22, height = 166))
      confidence = 88.5363388
    }
    [1] = {
      id = {}
      text = ",世界\n"
      boundingBox = (origin = (x = 7, y = 210), size = (width = 30, height = 83))
      confidence = 78.3088684
    }
}
```

Everything looks good, now.

#### Better configuration is better recognition

But&mdash;to make a point about better configuration making for better recognition&mdash;with a small, ***bad*** tweak we can get an odd result:

 1. Open **ContentView.swift**
 1. Locate the **Recognizer** for vertical Japanese
 1. Change the **imgDPI** from the correct value of 144 to the incorrect value of **72**

  ```swift
  RecognizedView(
      caption: "Japanese (vertical)",
      recognizer: Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 72)
  )
  ```

Re-run the app and we can see the text value `<*blank*>` with a confidence of 95%.  This value corresponds to the unexpected recognition of a single stroke inside the <span style="font-size: 1.1em">世</span> character as a whole other valid character:

<img height="404" src="Notes/static/guide/ipad_app_bad_blank_cropped.png"/>

#### Learning Tesseract

Configuration can matter a lot for Tesseract.  You might need to dig in if you don't immediately get good results.  Two resources we've consulted to get a quick picture of this configuration landscape were:

- **Is there a Minimum / Maximum Text Size? (It won’t read screen text!)**  <https://tesseract-ocr.github.io/tessdoc/FAQ-Old#is-there-a-minimum--maximum-text-size-it-wont-read-screen-text>

- **Improving the quality of the output** <https://tesseract-ocr.github.io/tessdoc/ImproveQuality>

The [Tesseract User Group](https://groups.google.com/g/tesseract-ocr) and its [Github Issues](https://github.com/tesseract-ocr/tesseract/issues) are also good resources.
