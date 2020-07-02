//
//  iOCRTests.swift
//  iOCRTests
//
//  Created by Zach Young on 6/24/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import XCTest

import libleptonica
import libtesseract

@testable import iOCR

class iOCRTests: XCTestCase {
    func testJapaneseVertical() {
        // There's spacing the OCR sees that I was having trouble encoding into
        // `want`, so I stripped all spaces for comparison

        let recognizer = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)
        defer { recognizer.destroy() }
        let got = recognizer.getAllText()

        XCTAssertEqual(got.filter { !$0.isWhitespace }, "Hello,世界")
    }

    func testHelloJapaneseHorizontal() {
        // There's spacing the OCR sees that I was having trouble encoding into
        // `want`, so I stripped all spaces for comparison

        let recognizer = Recognizer(imgName: "japanese", trainedDataName: "jpn")
        defer { recognizer.destroy() }
        let got = recognizer.getAllText()

        XCTAssertEqual(got.filter { !$0.isWhitespace }, "Hello,世界")
    }

    func testChineseTraditionalVertical1() {
        let recognizer = Recognizer(imgName: "chinese_traditional_vert", trainedDataName: "chi_tra_vert")
        defer { recognizer.destroy() }
        let got = recognizer.getAllText()

        XCTAssertEqual(got,
                       """
哈哈

我第一個到
終點了!

""")
    }
    
    /// Understanding something of Tesseract's process:  with the text **center-justified**, the recognizer gets it mostly right
    func testEnglishCenterJustify() {
        let recognizer = Recognizer(imgName: "english_ctr_just", trainedDataName: "eng",
                                    tessPIL: RIL_BLOCK, tessPSM: PSM_SINGLE_BLOCK)
        defer { recognizer.destroy() }
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
    
    /// Understanding something of Tesseract's process:  with the text **left-justified**, the recognizer gets it all correct
    func testEnglishLeftJustify() {
        let recognizer = Recognizer(imgName: "english_left_just", trainedDataName: "eng",
                                    tessPIL: RIL_BLOCK, tessPSM: PSM_SINGLE_BLOCK)
        defer { recognizer.destroy() }
        
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

    /// Originally a test to  assert that bad/false recognitions are rendered as `<*blank*>`;
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
        recognizer.destroy()
        recognizer = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)
        got = recognizer.getRecognizedRects()
        
        if got.count == 2 {
            XCTAssertEqual(got[0].text, "Hello\n\n")
            XCTAssertEqual(got[1].text, ",世界\n")
        } else {
            XCTFail(String(format: "got %d recognized rects, want 2", got.count))
        }

        recognizer.destroy()
    }
    
    func testGuideExample() {
        let tessAPI = TessBaseAPICreate()!
        let trainedDataFolder = Bundle.main.path(forResource: "tessdata", ofType: nil, inDirectory: "share")
        TessBaseAPIInit2(tessAPI, trainedDataFolder, "jpn", OEM_LSTM_ONLY)
        
        var image = getImage(from: UIImage(named: "japanese")!)
        TessBaseAPISetImage2(tessAPI, image)
        pixDestroy(&image)  // Leptonica method to manage Leptonica's PIX-type
        
        TessBaseAPISetSourceResolution(tessAPI, 144)  // w/default DPI: 72, no text recognized
        TessBaseAPISetPageSegMode(tessAPI, PSM_AUTO)
        
        TessBaseAPIGetUTF8Text(tessAPI)  // Pre-req for Tess[Page|Result]Iterator calls
        
        let iterator = TessBaseAPIGetIterator(tessAPI)
        let level = RIL_TEXTLINE
        
        let txt = TessResultIteratorGetUTF8Text(iterator, level)!
        let got = String(cString:txt)
        TessDeleteText(txt)
        XCTAssertEqual(got, "Hello, 世界\n")
        
        let confidence = TessResultIteratorConfidence(iterator, level)
        XCTAssertGreaterThan(confidence, 88)
        
        var x: Int32 = 0
        var y: Int32 = 0
        var wOffset: Int32 = 0
        var hOffset: Int32 = 0

        TessPageIteratorBoundingBox(iterator, level, &x, &y, &wOffset, &hOffset)
        XCTAssertEqual(x, 10)
        XCTAssertEqual(y, 14)
        XCTAssertEqual(wOffset, 160)
        XCTAssertEqual(hOffset, 43)
        
        // With RIL_TEXTLINE and PSM_AUTO, should not have more than one result
        XCTAssertEqual(TessPageIteratorNext(iterator, level), 0)
        TessPageIteratorDelete(iterator)
        
        TessBaseAPIEnd(tessAPI)
        TessBaseAPIDelete(tessAPI)
    }
}
