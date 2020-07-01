//
//  iOCR.swift
//  iOCR
//
//  Created by Zach Young on 6/24/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import UIKit
import SwiftUI

import libleptonica
import libtesseract

//--------------------------------------------------------------------------------

/// Convert UIImage to Pix format that Leptonica/Tesseract deal with
public func getImage(from image: UIImage) -> UnsafeMutablePointer<PIX>? {
    let data = image.pngData()!
    let rawPointer = (data as NSData).bytes
    let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)
    return pixReadMem(uint8Pointer, data.count)
}

//--------------------------------------------------------------------------------

public typealias TessBaseAPI = OpaquePointer

/// Pass in the name of a trainedData language file and get back a Tesseract API object
public func initOCR(trainedData: String) -> TessBaseAPI {
    let path = Bundle.main.path(forResource: "tessdata", ofType: nil, inDirectory: "share")
    let tesseract = TessBaseAPICreate()!
    TessBaseAPIInit2(tesseract, path, trainedData, OEM_LSTM_ONLY)
    return tesseract
}

/// Pass in an image with a tessAPI and get back some recognized text, hopefully.
/// If text cannot be recognized, get back ** No Text Found! **
public func performOCR(on: UIImage, tessAPI: TessBaseAPI) -> String {
    var image = getImage(from: on)
    defer { pixDestroy(&image) }

    TessBaseAPISetImage2(tessAPI, image)
    TessBaseAPISetSourceResolution(tessAPI, 72)
    TessBaseAPISetPageSegMode(tessAPI, PSM_AUTO)
    
    let charPtr: UnsafeMutablePointer<Int8>? = TessBaseAPIGetUTF8Text(tessAPI)
    defer { TessDeleteText(charPtr) }

    if let nncharPtr = charPtr {
        return String(cString: nncharPtr)
    } else {
        return "** No Text Found! **"
    }
}

public func deInitOCR(tessAPI: TessBaseAPI) {
    TessBaseAPIEnd(tessAPI)
    TessBaseAPIDelete(tessAPI)
}

//--------------------------------------------------------------------------------

/// Represents a "unit" of recognized text; the unit's size/scope is defined by TessPageIteratorLevel
struct RecognizedBlock {
    public var text: String
    public var boundingBox: CGRect
    public var confidence: Float
}

/// TessPageIteratorLevel (RIL = "Result Iterator Levels"):
/// RIL_BLOCK
/// RIL_PARA
/// RIL_TEXTLINE
/// RIL_WORD
/// RIL_SYMBOL
func recognizedBlocks(tessAPI: TessBaseAPI, level: TessPageIteratorLevel) -> [RecognizedBlock] {
    guard let resultIterator = TessBaseAPIGetIterator(tessAPI) else { return [] }
    defer { TessPageIteratorDelete(resultIterator)}
    
    var results = [RecognizedBlock]()
    
    repeat {
        if let block = block(from: resultIterator, for: level) {
            results.append(block)
        }
    } while (TessPageIteratorNext(resultIterator, level) > 0)
    
    return results
}

func block(from iterator: OpaquePointer, for level: TessPageIteratorLevel) -> RecognizedBlock? {
    guard let cString = TessResultIteratorGetUTF8Text(iterator, level) else { return nil }
    defer { TessDeleteText(cString) }
    
    let rect = makeBoundingRect(from: iterator, for: level)
    let text = String(cString: cString)
    let confidence = TessResultIteratorConfidence(iterator, level)
    
    return RecognizedBlock(text: text, boundingBox: rect, confidence: confidence)
}

func makeBoundingRect(from iterator: OpaquePointer, for level: TessPageIteratorLevel) -> CGRect {
    var originX: Int32 = 0
    var originY: Int32 = 0
    var widthOffset: Int32 = 0
    var heightOffset: Int32 = 0

    TessPageIteratorBoundingBox(iterator, level, &originX, &originY, &widthOffset, &heightOffset)

    return CGRect(
        x: .init(originX),
        y: .init(originY),
        width: .init(widthOffset - originX),
        height: .init(heightOffset - originY)
    )
}
