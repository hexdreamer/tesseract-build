//
//  Recognizer.swift
//  iOCR
//
//  Created by Zach Young on 6/29/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import Foundation
import SwiftUI

// Needed for ResultIteratorLevel, e.g. RIL_TEXTLINE
import libtesseract

class Recognizer {
    let img: UIImage
    let txt: String
    let rects: [RecognizedRectangle]
    
    init(
        trainedData: String,
        imgName: String
    ) {
        self.img = UIImage(named: imgName)!
        let tessAPI = initAPI(langDataName: trainedData, uiImage: self.img)
        
        var txt = getAllText(tessAPI: tessAPI)
        if (txt.filter { !$0.isWhitespace } == "") {
            txt="<*blank*>"
        }
        self.txt = txt

        self.rects = recognizedRectangles(tessAPI: tessAPI, level: RIL_TEXTLINE)
        
        deInitAPI(tessAPI: tessAPI)
    }
    
}
