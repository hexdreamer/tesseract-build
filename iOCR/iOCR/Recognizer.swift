//
//  Recognizer.swift
//  iOCR
//
//  Created by Zach Young on 6/29/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import Foundation
import SwiftUI

import libleptonica
import libtesseract


/// A unit of recognition that includes the recognized text, the text's location and size (in the image's coordinate space),
/// and the API's confidence in the recognition.
struct RecognizedRectangle {
    public var text: String
    public var boundingBox: CGRect
    public var confidence: Float
}

class Recognizer {
    public private(set) var recognizedRects: [RecognizedRectangle]
    let uiImage: UIImage

    private var tessAPI: OpaquePointer
    private var tessPIL: TessPageIteratorLevel

    /// Creates an object for reognizing text in images
    /// - Parameters:
    ///     - imgName: Assett name of the image to scan
    ///     - trainedDataName: The name portion of the trained data file to use, e.g.:
    ///         pass in `jpn_vert` for the file `jpn_vert.traineddata`.
    ///     - imgDPI: The image's DPI, default is `72`.
    ///     - tessPSM: A TessPageSegMode that affects how Tesseract treats/parses the image as a whole.
    ///         Many valid values, check Tesseract documentation; default is `PSM_AUTO`.
    ///     - tessPIL: A TessPageIteratorLevel that sets the scope/size of the objects you want recognized.
    ///         Valid values are: `RIL_BLOCK`, `RIL_PARA`, `RIL_TEXTLINE` (default), `RIL_WORD`, `RIL_SYMBOL`.
    init(
        imgName: String,
        trainedDataName: String,  // chi_tra, eng, jpn_vert
        imgDPI: Int32=72,
        tessPSM: TessPageSegMode=PSM_AUTO,
        tessPIL: TessPageIteratorLevel=RIL_TEXTLINE
) {
        self.recognizedRects = []
        self.uiImage = UIImage(named: imgName)!
        self.tessPIL = tessPIL
        self.tessAPI = TessBaseAPICreate()!
        
        let trainedDataFolder = Bundle.main.path(forResource: "tessdata", ofType: nil, inDirectory: "share")
        TessBaseAPIInit2(self.tessAPI, trainedDataFolder, trainedDataName, OEM_LSTM_ONLY)
       
        var image = getImage(from: self.uiImage)
        defer { pixDestroy(&image) }

        TessBaseAPISetImage2(self.tessAPI, image)
        TessBaseAPISetSourceResolution(self.tessAPI, imgDPI)
        TessBaseAPISetPageSegMode(self.tessAPI, tessPSM)
    }
    
    /// Frees  Tesseract API object
    public func destroy() {
        TessBaseAPIEnd(self.tessAPI)
        TessBaseAPIDelete(self.tessAPI)
    }

    /// Get back all recognized text in the entire image, hopefully.  If no text is recognized, get back ** No Text Found! **
    public func getAllText() -> String {
        let charPtr: UnsafeMutablePointer<Int8>? = TessBaseAPIGetUTF8Text(self.tessAPI)
        defer { TessDeleteText(charPtr) }

        if let nncharPtr = charPtr {
            return String(cString: nncharPtr)
        } else {
            return "** No Text Found! **"
        }
    }

    /// Get back all recognized objects for the set `tessPIL`
    public func getRecognizedRects() -> [RecognizedRectangle] {
        // Prime self.tessAPI
        _ = getAllText()
        
        guard let iterator = TessBaseAPIGetIterator(self.tessAPI) else { return [] }
        defer { TessPageIteratorDelete(iterator)}
        
        var rects = [RecognizedRectangle]()
        
        // If we got this far, iterator has at least one object, so step in and process
        repeat {
            // Text
            let charPtr: UnsafeMutablePointer<Int8>?
            charPtr = TessResultIteratorGetUTF8Text(iterator, self.tessPIL)!
            let text = String(cString: charPtr!)
            TessDeleteText(charPtr)
            
            // Rectangles; "offsets" are the (x,y)-point "opposite/diagonal" of origin
            var originX: Int32 = 0
            var originY: Int32 = 0
            var widthOffset: Int32 = 0
            var heightOffset: Int32 = 0
            TessPageIteratorBoundingBox(iterator, self.tessPIL, &originX, &originY, &widthOffset, &heightOffset)

            let width = widthOffset - originX
            let height = heightOffset - originY
            let cgRect = CGRect(x: CGFloat(originX), y: CGFloat(originY), width: CGFloat(width), height: CGFloat(height))
            
            // Confidence
            let confidence = TessResultIteratorConfidence(iterator, self.tessPIL)
            
            // -> RecognizedRectangle
            rects.append(
                RecognizedRectangle(text: text, boundingBox: cgRect, confidence: confidence)
            )
        } while (TessPageIteratorNext(iterator, self.tessPIL) > 0)
        
        // Special handling of bad/false recognitions
        // Originally showed up when Japanese images (with native 144dpi) were run through Tesseract at 72dpi
        for i in 0..<rects.count {
            if (rects[i].text.filter { !$0.isWhitespace } == "") {
                rects[i].text = "<*blank*>"
            }
        }

        self.recognizedRects = rects
        return rects
    }
    
    public func setDPI(imgDPI: Int32) {
        TessBaseAPISetSourceResolution(self.tessAPI, imgDPI)
    }
}

/// Convert UIImage to format/structure that Leptonica and Tesseract deal with
public func getImage(from image: UIImage) -> UnsafeMutablePointer<PIX>? {
    let data = image.pngData()!
    let rawPointer = (data as NSData).bytes
    let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)
    return pixReadMem(uint8Pointer, data.count)
}
