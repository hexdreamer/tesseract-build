//
//  iOCRTests.swift
//  iOCRTests
//
//  Created by Zach Young on 6/24/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import XCTest
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
}
