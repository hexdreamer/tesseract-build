//
//  iOCRTests.swift
//  iOCRTests
//
//  Created by Zach Young on 9/17/20.
//

import XCTest
@testable import iOCR_macOS

import libleptonica
import libtesseract


class StraightUpRecognitionTest: XCTestCase {
    /// Build a recognition pipeline/chain from the bottom-up.
    ///
    /// The other tests rely on the Recognizer class which wraps this all up.
    func testGuideExample() {
        
        let nsImage = NSImage(named: NSImage.Name("japanese"))!
        let data = nsImage.tiffRepresentation!
        let rawPointer = (data as NSData).bytes
        let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)

        var image = pixReadMem(uint8Pointer, data.count)   // var because image is passed as in-out, so must be mutable

        let trainedDataFolder = Bundle.main.path(
            forResource: "tessdata", ofType: nil, inDirectory: "share")

        let tessAPI = TessBaseAPICreate()!
        TessBaseAPIInit2(tessAPI, trainedDataFolder, "jpn", OEM_LSTM_ONLY)
        TessBaseAPISetImage2(tessAPI, image)

        pixDestroy(&image)                                 // Leptonica method to manage Leptonica's PIX-type
        
        TessBaseAPISetSourceResolution(tessAPI, 144)       // w/Tesseract's default of 72, no text recognized
        TessBaseAPISetPageSegMode(tessAPI, PSM_AUTO)       // Let Tesseract decide how to see the image
        
        TessBaseAPIRecognize(tessAPI, nil)                    // Pre-req for Tess[Page|Result]Iterator calls
                                                           // We could get the text back from this method call
        
        let iterator = TessBaseAPIGetIterator(tessAPI)     // Get an iterator...
        let level = RIL_TEXTLINE                           // at the level of an individual "line of text"
    
        // Get text
        let txt = TessResultIteratorGetUTF8Text(iterator, level)!
        let got = String(cString:txt)
        TessDeleteText(txt)
        XCTAssertEqual(got, "Hello, 世界\n")
     
        // Get confidence
        let confidence = TessResultIteratorConfidence(iterator, level)
        XCTAssertGreaterThan(confidence, 88)
        
        // Get locations/rectangles around recognized text
        var x1: Int32 = 0
        var y1: Int32 = 0
        var x2: Int32 = 0
        var y2: Int32 = 0

        TessPageIteratorBoundingBox(iterator, level, &x1, &y1, &x2, &y2)
        XCTAssertEqual(x1, 10)
        XCTAssertEqual(y1, 14)
        XCTAssertEqual(x2, 160)
        XCTAssertEqual(y2, 43)
        
        // With RIL_TEXTLINE and PSM_AUTO, should have had only one result for this image
        XCTAssertEqual(TessPageIteratorNext(iterator, level), 0)
        
        // Teardown
        TessPageIteratorDelete(iterator)
        TessBaseAPIEnd(tessAPI)
        TessBaseAPIDelete(tessAPI)
    }
}

class iOCRRecognizerTests: XCTestCase {
    func testJapaneseVertical() {
        // There's spacing the OCR sees that I was having trouble encoding into
        // the string, so I stripped all spaces for comparison

        let recognizer = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)
        let got = recognizer.getAllText()

        XCTAssertEqual(got.filter { !$0.isWhitespace }, "Hello,世界")
    }

    func testHelloJapaneseHorizontal() {
        // There's spacing the OCR sees that I was having trouble encoding into
        // the string, so I stripped all spaces for comparison

        let recognizer = Recognizer(imgName: "japanese", trainedDataName: "jpn")
        let got = recognizer.getAllText()

        XCTAssertEqual(got.filter { !$0.isWhitespace }, "Hello,世界")
    }

    func testChineseTraditionalVertical1() {
        let recognizer = Recognizer(imgName: "chinese_traditional_vert", trainedDataName: "chi_tra_vert")
        let got = recognizer.getAllText()

        XCTAssertEqual(got,
                       """
哈哈

我第一個到
終點了!

""")
    }
    
    /// Understanding something of Tesseract's process:  with the text *center-justified*, the recognizer gets it **mostly** right
    func testEnglishCenterJustify() {
        let recognizer = Recognizer(imgName: "english_ctr_just", trainedDataName: "eng",
                                    tessPSM: PSM_SINGLE_BLOCK, tessPIL: RIL_BLOCK)
        let got = recognizer.getAllText()

        // Note that the 4th-to-last line is 'foruseina'; should be 'for use in a'
        let want = """
Welcome to
Hexdreamer's
dream of a
simple-to-
understand
guide for
integrating a C-
API, and
specifically
Tesseract
OCR, into an
Xcode project
foruseina
dream iOS
manga-reader
app.

"""
        XCTAssertEqual(got, want)
        
        // Only true if RIL_BLOCK or RIL_PARA is set
        let rects = recognizer.getRecognizedRects()
        XCTAssertEqual(rects.count, 1)
    }
    
    /// Understanding something of Tesseract's process:  with the text *left-justified*, the recognizer gets it **all** correct
    func testEnglishLeftJustify() {
        let recognizer = Recognizer(imgName: "english_left_just", trainedDataName: "eng",
                                    tessPSM: PSM_SINGLE_BLOCK, tessPIL: RIL_BLOCK)
        
        // Note that the 4th-to-last line is 'for use in a'; CORRECT!
        let want = """
Welcome to
Hexdreamer's
dream of a
simple-to-
understand
guide for
integrating a C-
API, and
specifically
Tesseract
OCR, into an
Xcode project
for use in a
dream iOS
manga-reader
app.

"""
        let got = recognizer.getAllText()
        
        XCTAssertEqual(got, want)
        
        // Only true if RIL_BLOCK or RIL_PARA is set
        let rects = recognizer.getRecognizedRects()
        XCTAssertEqual(rects.count, 1)
    }

    /// Originally a test to assert that the Recognizer rendered bad/false recognitions as `<*blank*>`;
    /// now also a lesson in getting the image's DPI correct.
    func testBlankVsNonBlank() {
        // This image's DPI is 144, but running at 72 DPI yields false recognition (<*blank*>)
        var recognizer = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 72)
        var got = recognizer.getRecognizedRects()

        if got.count == 3 {
            XCTAssertEqual(got[0].text, "Hello\n\n")
            XCTAssertEqual(got[1].text, ",世界\n\n")
            XCTAssertEqual(got[2].text, "<*blank*>")

        } else {
            XCTFail(String(format: "got %d recognized rects, want 3", got.count))
        }

        // Now run test with correct DPI for only true recognitions
        recognizer = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)
        got = recognizer.getRecognizedRects()
        
        if got.count == 2 {
            XCTAssertEqual(got[0].text, "Hello\n\n")
            XCTAssertEqual(got[1].text, ",世界\n")
        } else {
            XCTFail(String(format: "got %d recognized rects, want 2", got.count))
        }
    }
}

