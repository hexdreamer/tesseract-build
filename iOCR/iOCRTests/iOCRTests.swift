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
    func testHelloJapaneseVertical() {
        let recognizer = Recognizer(trainedData: "jpn_vert", imgName: "hello_japanese_vertical")
        let want = "Hello,世界"
        let got = recognizer.txt

        // There's spacing the OCR sees that I was having trouble encoding into
        // `want`, so I stripped all spaces for comparison
        XCTAssertEqual(got.filter { !$0.isWhitespace }, want)
    }

    func testHelloJapaneseHorizontal() {
        let recognizer = Recognizer(trainedData: "jpn", imgName: "hello_japanese_horizontal")
        let want = "Hello,世界"
        let got = recognizer.txt

        // There's spacing the OCR sees that I was having trouble encoding into
        // `want`, so I stripped all spaces for comparison
        XCTAssertEqual(got.filter { !$0.isWhitespace }, want)
    }

    func testChineseTraditionalVertical1() {
        let recognizer = Recognizer(trainedData: "chi_tra_vert", imgName: "traditional_chinese_vertical_1")
        let want = """
哈哈

我第一個到
終點了!

"""
        let got = recognizer.txt
        
        XCTAssertEqual(got, want)
 
}

    func testChineseTraditionalVertical2() {
        let recognizer = Recognizer(trainedData: "chi_tra_vert", imgName: "traditional_chinese_vertical_2")
        let want = """
如果終點地下
有地雷怎麼辦!

"""
        let got = recognizer.txt
        
        XCTAssertEqual(got, want)
    }
    
    func testGuideExample() {
        let tessAPI = TessBaseAPICreate()!
        
        let trainedDataFolder = Bundle.main.path(forResource: "tessdata", ofType: nil, inDirectory: "share")
        TessBaseAPIInit2(tessAPI, trainedDataFolder, "jpn_vert", OEM_LSTM_ONLY)

        var image = getImage(from: UIImage(named: "hello_japanese_vertical")!)
        TessBaseAPISetImage2(tessAPI, image)
        // Leptonica method to manage Leptonica's PIX-type
        pixDestroy(&image)

        TessBaseAPISetSourceResolution(tessAPI, 72)
        TessBaseAPISetPageSegMode(tessAPI, PSM_AUTO)

        // This is a pre-req for any TessResultIterator call
        TessBaseAPIGetUTF8Text(tessAPI)

        let iterator = TessBaseAPIGetIterator(tessAPI)
        let level = RIL_TEXTLINE
        
        var txt = TessResultIteratorGetUTF8Text(iterator, level)!
        var confidence = TessResultIteratorConfidence(iterator, level)
        
        var x: Int32 = 0
        var y: Int32 = 0
        // wO and hO are widthOffset and heighOffset
        var wO: Int32 = 0
        var hO: Int32 = 0
        TessPageIteratorBoundingBox(iterator, level, &x, &y, &wO, &hO)
        
        XCTAssertEqual(String(cString:txt).filter { !$0.isWhitespace }, "Hello")
        
        // Don't know actual coordinates or confidence, other than nothing should be 0
        XCTAssertNotEqual(x, 0)
        XCTAssertNotEqual(y, 0)
        XCTAssertNotEqual(wO, 0)
        XCTAssertNotEqual(hO, 0)
        XCTAssertGreaterThan(confidence, 0)
        
        // Get next result
        XCTAssertNotEqual(TessPageIteratorNext(iterator, level), 0)
        
        x  = 0
        y  = 0
        wO  = 0
        hO = 0
        TessDeleteText(txt)
        confidence = 0

        txt = TessResultIteratorGetUTF8Text(iterator, level)!
        confidence = TessResultIteratorConfidence(iterator, level)
        TessPageIteratorBoundingBox(iterator, level, &x, &y, &wO, &hO)
        
        XCTAssertEqual(String(cString:txt).filter { !$0.isWhitespace }, ",世界")
        XCTAssertNotEqual(x, 0)
        XCTAssertNotEqual(y, 0)
        XCTAssertNotEqual(wO, 0)
        XCTAssertNotEqual(hO, 0)
        XCTAssertGreaterThan(confidence, 0)

        TessBaseAPIEnd(tessAPI)
        TessBaseAPIDelete(tessAPI)
    }
}
