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
        let recognizer = Recognizer(imgName: "japanese_vert", trainedLangName: "jpn_vert")
        let want = "Hello,世界"
        let got = recognizer.allTxt
        
        // There's spacing the OCR sees that I was having trouble encoding into
        // `want`, so I stripped all spaces for comparison
        XCTAssertEqual(got.filter { !$0.isWhitespace }, want)
    }

    func testHelloJapaneseHorizontal() {
        let recognizer = Recognizer(imgName: "japanese", trainedLangName: "jpn")
        let want = "Hello,世界"
        let got = recognizer.allTxt

        // There's spacing the OCR sees that I was having trouble encoding into
        // `want`, so I stripped all spaces for comparison
        XCTAssertEqual(got.filter { !$0.isWhitespace }, want)
    }

    func testChineseTraditionalVertical1() {
        let recognizer = Recognizer(imgName: "chinese_traditional_vert", trainedLangName: "chi_tra_vert")
        let want = """
哈哈

我第一個到
終點了!

"""
        let got = recognizer.allTxt
        
        XCTAssertEqual(got, want)
        
    }
    
    /// Understanding something of Tesseract's process:  with the text **center-justified**, the recognizer gets it mostly right
    func testEnglishCenterJustify() {
        let recognizer = Recognizer(imgName: "english_ctr_just", trainedLangName: "eng",
                                    tessPIL: RIL_BLOCK, tessPSM: PSM_SINGLE_BLOCK)
        
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
        let got = recognizer.allTxt
        
        XCTAssertEqual(got, want)
        
        // Only true if RIL_BLOCK or RIL_PARA is set
        XCTAssertEqual(recognizer.recognizedRects.count, 1)
    }
    
    /// Understanding something of Tesseract's process:  with the text **left-justified**, the recognizer get it all correct
    func testEnglishLeftJustify() {
        let recognizer = Recognizer(imgName: "english_left_just", trainedLangName: "eng",
                                    tessPIL: RIL_BLOCK, tessPSM: PSM_SINGLE_BLOCK)
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
        let got = recognizer.allTxt
        
        XCTAssertEqual(got, want)
        
        // Only true if RIL_BLOCK or RIL_PARA is set
        XCTAssertEqual(recognizer.recognizedRects.count, 1)
    }
    func testBlank() {
        let recognizer = Recognizer(imgName: "japanese_vert", trainedLangName: "jpn_vert")
        let want = ["Hello",",世界","<*blank*>"]
        let got = recognizer.recognizedRects
        
        for i in 0...2 {
            XCTAssertEqual(
                got[i].text.filter{ !$0.isWhitespace },
                want[i])
        }
    }
    
    func testGuideExample() {
        let tessAPI = TessBaseAPICreate()!
        let trainedDataFolder = Bundle.main.path(
            forResource: "tessdata", ofType: nil, inDirectory: "share")
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
        
        // For PIL and PSM, should not have more than one result
        XCTAssertEqual(TessPageIteratorNext(iterator, level), 0)
        TessPageIteratorDelete(iterator)
        
        TessBaseAPIEnd(tessAPI)
        TessBaseAPIDelete(tessAPI)
    }
}
