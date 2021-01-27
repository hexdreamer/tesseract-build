//
//  ContentView.swift
//  iOCR
//
//  Created by Zach Young on 9/17/20.
//

import SwiftUI

import libtesseract

/// Run this demo as **iPad Pro (12.9-inch)**
struct ContentView: View {
    
    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
        ]
        
        LazyVGrid(columns: columns) {
            RecognizedView(
                caption: "Japanese (horizontal)",
                recognizer: Recognizer(imgName: "japanese", trainedDataName: "jpn", imgDPI: 144))
            RecognizedView(
                caption: "Japanese (vertical)",
                recognizer: Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)
            )
            RecognizedView(
                caption: "Traditional Chinese",
                recognizer: Recognizer(imgName: "chinese_traditional_vert", trainedDataName: "chi_tra_vert"))
            
            RecognizedView(
                caption: "English (left-justified)",
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
