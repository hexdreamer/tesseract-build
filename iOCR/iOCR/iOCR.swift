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

/// an instance of the Tesseract API
public typealias TessBaseAPI = OpaquePointer

public func initializeOCR(trainedData: String) -> TessBaseAPI {
    let path = Bundle.main.path(forResource: "tessdata", ofType: nil, inDirectory: "share")
    setenv("TESSDATA_PREFIX", path, 1)
    
    let tesseract = TessBaseAPICreate()!
    TessBaseAPISetVariable(tesseract, "textord_old_xheight", "0")
    TessBaseAPIInit2(tesseract, path, trainedData, OEM_LSTM_ONLY)
    
    return tesseract
}

public func performOCR(on: UIImage, tessAPI: TessBaseAPI) -> String {
    var pix = createPix(from: on)
    defer { pixDestroy(&pix) }

    TessBaseAPISetImage2(tessAPI, pix)
    TessBaseAPISetSourceResolution(tessAPI, 72)
    TessBaseAPISetPageSegMode(tessAPI, PSM_AUTO)
    
    // Why is it okay to declare charPtr with AND without `?`
    let charPtr: UnsafeMutablePointer<Int8>? = TessBaseAPIGetUTF8Text(tessAPI)
    defer { TessDeleteText(charPtr) }

    if let nncharPtr = charPtr {
        return String(cString: nncharPtr)
    } else {
        return "Hmm... No Text Found!"
    }
}

public func deInitOCR(tessAPI: TessBaseAPI) {
    TessBaseAPIEnd(tessAPI)
    TessBaseAPIDelete(tessAPI)
}

typealias Pix = UnsafeMutablePointer<PIX>?

private func createPix(from image: UIImage) -> Pix {
    let data = image.pngData()!
    let rawPointer = (data as NSData).bytes
    let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)
    return pixReadMem(uint8Pointer, data.count)
}

/// Result Iterator Levels:
/// RIL_BLOCK
/// RIL_PARA
/// RIL_TEXTLINE
/// RIL_WORD
/// RIL_SYMBOL
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

/// Represents a "unit" of recognized text; the unit's size/scope is defined by TessPageIteratorLevel
struct RecognizedBlock {
    public var text: String
    public var boundingBox: CGRect
    public var confidence: Float
}


func block(from iterator: OpaquePointer, for level: TessPageIteratorLevel) -> RecognizedBlock? {
    guard let cString = TessResultIteratorGetUTF8Text(iterator, level) else { return nil }
    defer { TessDeleteText(cString) }
    
    let rect = makeBoundingRect(from: iterator, for: level)
    let text = String(cString: cString)
    let confidence = TessResultIteratorConfidence(iterator, level)
    
    return RecognizedBlock(text: text, boundingBox: rect, confidence: confidence)
}


func recognizedBlocks(tessAPI: TessBaseAPI, level: TessPageIteratorLevel) -> [RecognizedBlock] {
    guard let resultIterator = TessBaseAPIGetIterator(tessAPI)
        else { return [] }
    
    defer { TessPageIteratorDelete(resultIterator)}
    
    var results = [RecognizedBlock]()
    
    repeat {
        if let block = block(from: resultIterator, for: level) {
            results.append(block)
        }
    } while (TessPageIteratorNext(resultIterator, level) > 0)
    
    return results
}
