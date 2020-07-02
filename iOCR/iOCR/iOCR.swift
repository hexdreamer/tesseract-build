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

/// Convert UIImage to format/structure that Leptonica and Tesseract deal with
public func getImage(from image: UIImage) -> UnsafeMutablePointer<PIX>? {
    let data = image.pngData()!
    let rawPointer = (data as NSData).bytes
    let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)
    return pixReadMem(uint8Pointer, data.count)
}

//--------------------------------------------------------------------------------

/// Create a Tesseract API object.
/// - Parameters:
///     - langDataName: the name portion of the trained data file to use, e.g.: for the file `jpn_vert.traineddata`, pass in **jpn_vert**
///     - uiImage: an image with text to recognize
public func initAPI(trainedLangName: String, uiImage: UIImage) -> OpaquePointer {
    let path = Bundle.main.path(forResource: "tessdata", ofType: nil, inDirectory: "share")
    let tessAPI = TessBaseAPICreate()!
    TessBaseAPIInit2(tessAPI, path, trainedLangName, OEM_LSTM_ONLY)
    
    var image = getImage(from: uiImage)
    defer { pixDestroy(&image) }

    TessBaseAPISetImage2(tessAPI, image)
    TessBaseAPISetSourceResolution(tessAPI, 72)
    TessBaseAPISetPageSegMode(tessAPI, PSM_AUTO)
    
    return tessAPI
}

public func setPageSegMode(tessAPI: OpaquePointer, psm: TessPageSegMode) {
    TessBaseAPISetPageSegMode(tessAPI, psm)
}

/// Get back all recognized text in the entire image, hopefully.  If no text is recognized, get back ** No Text Found! **
public func getAllText(tessAPI: OpaquePointer) -> String {
    let charPtr: UnsafeMutablePointer<Int8>? = TessBaseAPIGetUTF8Text(tessAPI)
    defer { TessDeleteText(charPtr) }

    if let nncharPtr = charPtr {
        return String(cString: nncharPtr)
    } else {
        return "** No Text Found! **"
    }
}

//--------------------------------------------------------------------------------

/// A unit of recognition that includes the recognized text, the text's location and size (in the image's coordinate space),
/// and the API's confidence in this recognition.
struct RecognizedRectangle {
    public var text: String
    public var boundingBox: CGRect
    public var confidence: Float
}

/// Returns an array of recognized objects; `performOCR()` must be called before calling this function.
///
/// - Parameters:
///     - tessAPI: A Tesseract API object; `performOCR()` must have already been called on it.
///     - level: A TessPageIteratorLevel that defines the scope/size of the recognition object.
///         Valid values are: `RIL_BLOCK`, `RIL_PARA`, `RIL_TEXTLINE`, `RIL_WORD`, `RIL_SYMBOL`
///
func  recognizedRectangles(tessAPI: OpaquePointer, level: TessPageIteratorLevel) -> [RecognizedRectangle] {
    guard let iterator = TessBaseAPIGetIterator(tessAPI) else { return [] }
    defer { TessPageIteratorDelete(iterator)}

    var rects = [RecognizedRectangle]()
    repeat {
        // Text
        let txt = TessResultIteratorGetUTF8Text(iterator, level)!
        defer { TessDeleteText(txt) }
        let txtStr = String(cString: txt)
        
        // Rectangles
        var originX: Int32 = 0
        var originY: Int32 = 0
        // these "offsets" are the (x,y)-point "opposite" of origin
        var widthOffset: Int32 = 0
        var heightOffset: Int32 = 0

        TessPageIteratorBoundingBox(iterator, level, &originX, &originY, &widthOffset, &heightOffset)

        let width = widthOffset - originX
        let height = heightOffset - originY
        let cgRect = CGRect(x: CGFloat(originX), y: CGFloat(originY), width: CGFloat(width), height: CGFloat(height))
        
        // Confidence
        let confidence = TessResultIteratorConfidence(iterator, level)
        
        // RecognizedRectangle
        rects.append(RecognizedRectangle(text: txtStr, boundingBox: cgRect, confidence: confidence))
    } while (TessPageIteratorNext(iterator, level) > 0)

    return rects
}

//--------------------------------------------------------------------------------

/// Frees a Tesseract API object
public func deInitAPI(tessAPI: OpaquePointer) {
    TessBaseAPIEnd(tessAPI)
    TessBaseAPIDelete(tessAPI)
}
