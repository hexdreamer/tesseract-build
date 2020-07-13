# Configuring Xcode

Steps I went through learning how to create an Xcode project around a C-API.

## Integrating Tesseract into Xcode

### Create the project

1. **File** &rarr; **New Project**

1. A **Single View App** is a great template for this guide, **Next**

1. Add **Product Name**, I've named mine *iOCR*, **Next**

1. Choose your project's location, I chose `$PROJECTDIR`, **Create**

### Write a bit of code

1. **File** &rarr; **New** &rarr; **File...**

1. Choose **Swift File**, **Next**

1. **Save As:** **iOCR**, **Group: iOCR (folder under iOCR project)**, **Create**

1. Insert this snippet into **iOCR.swift**:

    ```swift
    import libleptonica
    import libtesseract
    ```

1. Save that file, and my first error is:

    ```none
    No such module 'libleptonica'
    ```

    <!--![no such module 'libtesseract'](../Notes/static/guide/err_no_such_module_leptonica.png)-->
    <img height="53" src="../Notes/static/guide/err_no_such_module_leptonica.png"/>

### No such module

Our two libraries, Leptonica and Tesseract, need to be copied into the project and made known to Xcode as 2 different modules.

1. Copy over the headers into a new **dependencies** folder:

    ```zsh
    ditto $ROOT/include/leptonica iOCR/iOCR/dependencies/include/leptonica
    ditto $ROOT/include/tesseract iOCR/iOCR/dependencies/include/tesseract
    ```

    I'm ignoring the libs for now because the error is about modules.

1. Right-click the iOCR folder in the project navigator and choose **Add Files to "iOCR"**:

    ![Add dependencies to iOCR folder](../Notes/static/guide/guide_add_dependencies.png)

1. Select the folder **iOCR/iOCR/dependencies**, check that **Create groups** is selected, **Add**

1. **File** &rarr; **New...** &rarr; **File**, scroll down to **Other** and choose **Empty**

1. Create **iOCR/iOCR/dependencies/module.modulemap**, in the **Group: dependencies**, with the following contents:

    ```swift
    module libtesseract {
        header "include/tesseract/capi.h"
        export *
    }

    module libleptonica {
        header "include/leptonica/allheaders.h"
        export *
    }
    ```

1. My project now looks like:

    <img height="241" src="../Notes/static/guide/module_final_structure_cropped.png"/>

1. Set the **SWIFT_INCLUDE_PATHS** in the project's build settings to **$(PROJECT_DIR)/../Root/include/\*\***:

    <img src="../Notes/static/guide/2_swift_include_paths_cropped.png"/>

    Xcode converts the **/\*\*** part at the end of the path to that **recursive** value in the bottom-right of image.

1. **Product** &rarr; **Build**, and that error is cleared:

    <img height="200" src="../Notes/static/guide/build_succeeded.png"/>