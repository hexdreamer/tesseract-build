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
    var jpn: Recognizer
    var jpn_vert: Recognizer
    var chi_trad_vert: Recognizer
    var eng: Recognizer
    
    var body: some View {
        return VStack {
            HStack{
                ImageRectsAndText(recognizer: jpn)
                ImageRectsAndText(recognizer: jpn_vert)
            }
            HStack {
                ImageRectsAndText(recognizer: chi_trad_vert)
                ImageRectsAndText(recognizer: eng)
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

// This simple demo has at most 3 recognized recognized objects for any image
var Colors = [Color.red, Color.yellow, Color.purple]

struct ImageRectsAndText: View {
    private var recognizer: Recognizer
    
    init(
        recognizer: Recognizer
    ) {
        self.recognizer = recognizer
    }
    
    var body: some View {
        VStack {
            ZStack {  // image and super-imposed colored rectangles
                Image(uiImage:recognizer.uiImage).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                ForEach(0..<recognizer.recognizedRects.count) { i in
                    Path { path in
                        let rect = self.recognizer.recognizedRects[i]
                        path.addRect(rect.boundingBox)
                    }.stroke(Colors[i], lineWidth: 2)
                }
            }
            VStack {
                ForEach(0..<recognizer.recognizedRects.count) { i in
                    ConfidentText(rect: self.recognizer.recognizedRects[i], color: Colors[i])
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .border(Color.black, width: 2)
    }
}

struct ConfidentText: View {
    private var color: Color
    private var txt: String
    
    init(
        rect: RecognizedRectangle,
        color: Color
    ) {
        self.color = color
        self.txt = String(format:"%@ - %.2f",
                          rect.text.trimmingCharacters(in: .whitespacesAndNewlines), rect.confidence)
    }

    var body: some View {
        Text(txt)
            .font(.system(size: 30))
            .border(self.color, width: 2)
            .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}
