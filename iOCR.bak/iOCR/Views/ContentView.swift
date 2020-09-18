//
//  ContentView.swift
//  iOCR
//
//  Created by Zach Young on 6/24/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import SwiftUI

import libtesseract

/// Run this demo as **iPad Pro (12.9-inch)**
struct ContentView: View {
    
    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        
        LazyVGrid(columns: columns) {
            RecognizedView(
                recognizer: Recognizer(imgName: "japanese", trainedDataName: "jpn", imgDPI: 144))
            RecognizedView(
                recognizer: Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)
            )
            RecognizedView(
                recognizer: Recognizer(imgName: "chinese_traditional_vert", trainedDataName: "chi_tra_vert"))
            
            RecognizedView(
                recognizer: Recognizer(
                    imgName: "english_left_just_square", trainedDataName: "eng",
                    tessPSM: PSM_SINGLE_BLOCK, tessPIL: RIL_BLOCK
                )
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
