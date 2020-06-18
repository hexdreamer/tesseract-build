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

With everything looking like it was built and installed, we can quickly check Tesseract itself using the **tesseract** command-line (CL) program.  Let's run **test_tesseract.sh**, which will download some trained data for horizontal and vertical Japanese scripts and then run OCR on some simple images.


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

### tesseract command-line

Using this image as my sample comic book panel with Japanese text:

<img src="Notes/static/02-panel.jpg" width="1000">

The basic command looks like:

```zsh
% tesseract 02-panel.jpg stdout -l jpn_vert
```

Setting the `--dpi` seems to make a big difference in how the text is recognized:

<table>
<tr><td>dpi</td><td>text</td></tr>
<tr>
<td>72</td>
<td>(doesn't do anything)</td>
</tr>

<tr>
<td>70</td>
<td>
<pre>
Estimating resolution as 660
みんなが

そう言うので、
お医者さんに
聞いてみたん

心臓の音が
びとつしか
聞こえないから、
双子ではないと。
</pre>
</td>
</tr>

<tr>
<td>200</td>
<td>
<pre>
みんなが
そう言うので、
お医者さんに
</pre>
</td>
</tr>

<tr>
<td>1000</td>
<td>
<pre>
Detected 3 diacritics


みんなが

そう言うので、
お医者さんに
問いてみたん





心臓の音が
びとつしか
聞こえないから、
双子ではないと。
</pre>
</td>
</tr>
</table>

The results of 70 dpi and 1000 dpi are very close to being equal.  70 is correct, to my eyes, while 1000 differs on the first character of line 4:

<table>
<tr><td>70 dpi</td><td>1000 dpi</td></tr>
<tr>
<td style="font-size:1.5em; background-color: #e6ffed">聞</td>
<td style="font-size:1.5em; background-color: #ffeef0">問</td></tr>
</table>

The text actually looks like it could be correct, and it mostly is.  The glaring exception in the second line being <emphasis style="font-size: 1.25em">ひびひ</emphasis> where it should be <emphasis style="font-size: 1.25em">ひ</emphasis>:

I ran some tests with the tesseract command-line program and found some options which started saving intermediate versions of the image as it passed through the command-line's pre-processes:

```none
tesseract cropped2.jpg stdout -l jpn_vert \
  -c tessedit_display_outwords=1 \
  -c tessedit_dump_pageseg_images=1 \
  -c tessedit_write_images=1 \
  -c textord_debug_tabfind=1 \
  -c textord_show_final_blobs=1 \
  -c textord_show_initial_words=1 \
  -c textord_show_new_words=1 \
  -c textord_tabfind_show_images=1 \
  -c textord_tabfind_show_partitions=1 \
  -c textord_tablefind_show_mark=1 \
  -c textord_tablefind_show_stats=1 \
  -c wordrec_display_segmentations=1 \
  -c wordrec_display_splits=1
```

### Input image

The tesseract command-line pre-processes the input image, at the very least converting to halftone, and it looks like also upscaling (but I'm still foggy on these distinctions).

`-c tessedit_write_images=1` dumps this input image to **tessinput.tif**.

### Page Segmentation

```-c tessedit_dump_pageseg_images=1 -c textord_tabfind_show_images=1``` produce a PDF of the steps in page segmentation:

![Pageseg images](Notes/static/02-pageseg-images.png)

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