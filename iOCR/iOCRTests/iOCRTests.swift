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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testHelloJapaneseVertical() {
        // There's spacing the OCR sees that I was having trouble encoding into
        // `want`, so I stripped all spaces for comparison
        initializeOCR(trainedData: "jpn_vert")

        let img = UIImage(named: "hello_japanese_vertical")!
        let want = "Hello,世界"
        let got = performOCR(on: img)

        XCTAssertEqual(got.filter { !$0.isWhitespace }, want)
        
        deInitOCR()
    }

    func testHelloJapaneseHorizontal() {
        // There's spacing the OCR sees that I was having trouble encoding into
        // `want`, so I stripped all spaces for comparison
        initializeOCR(trainedData: "jpn")
        
        let img = UIImage(named: "hello_japanese_horizontal")!
        let want = "Hello,世界"
        let got = performOCR(on: img)
        
        XCTAssertEqual(got.filter { !$0.isWhitespace }, want)
        
        deInitOCR()
    }
    
    func testChineseTraditionalVertical1() {
        initializeOCR(trainedData: "chi_tra_vert")
        
        let img = UIImage(named: "traditional_chinese_vertical_1")!
        let want = """
哈哈

我第一個到
終點了!

"""
        let got = performOCR(on: img)
        
        XCTAssertEqual(got, want)
 
        deInitOCR()
}

    func testChineseTraditionalVertical2() {
        initializeOCR(trainedData: "chi_tra_vert")
        
        let img = UIImage(named: "traditional_chinese_vertical_2")!
        let want = """
如果終點地下
有地雷怎麼辦!

"""
        let got = performOCR(on: img)
        
        XCTAssertEqual(got, want)

        deInitOCR()
    }
}

