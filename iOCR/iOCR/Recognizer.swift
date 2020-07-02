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
    var img: UIImage
    var allTxt: String
    var recognizedRects: [RecognizedRectangle]

    init(
        imgName: String,
        trainedLangName: String,  // chi_tra, eng, jpn_vert
        imgDPI: Int=72,
        tessPIL: TessPageIteratorLevel=RIL_TEXTLINE,
        tessOEM: TessOcrEngineMode=OEM_LSTM_ONLY,
        tessPSM: TessPageSegMode=PSM_AUTO
    ) {
        self.img = UIImage(named: imgName)!
        let tessAPI = initAPI(trainedLangName: trainedLangName, uiImage: self.img)
        setPageSegMode(tessAPI: tessAPI, psm: tessPSM)

        var txt = getAllText(tessAPI: tessAPI)
        if (txt.filter { !$0.isWhitespace } == "") {
            txt="<*blank*>"
        }
        self.allTxt = txt

        self.recognizedRects = recognizedRectangles(tessAPI: tessAPI, level: tessPIL)
        
        for i in 0..<self.recognizedRects.count {
            if (self.recognizedRects[i].text.filter { !$0.isWhitespace } == "") {
                self.recognizedRects[i].text = "<*blank*>"
            }
        }

        deInitAPI(tessAPI: tessAPI)
    }
}
