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
    let blocks: [RecognizedBlock]
    
    init(
        trainedData: String,
        imgName: String
    ) {
        let tessAPI = initOCR(trainedData: trainedData)
        
        self.img = UIImage(named: imgName)!
        self.txt = performOCR(on: self.img, tessAPI: tessAPI)
        self.blocks = recognizedBlocks(tessAPI: tessAPI, level: RIL_TEXTLINE)
        
        deInitOCR(tessAPI: tessAPI)
        
    }
    
}
