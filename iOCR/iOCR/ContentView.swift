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
        return VStack {
            HStack{
                ImageBlocksAndText(trainedData: "jpn_vert", imgName: "hello_japanese_vertical")
                ImageBlocksAndText(trainedData: "jpn", imgName: "hello_japanese_horizontal")
            }
            HStack {
                ImageBlocksAndText(trainedData: "chi_tra_vert", imgName: "traditional_chinese_vertical_1")
                ImageBlocksAndText(trainedData: "chi_tra_vert", imgName: "traditional_chinese_vertical_2")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func drawOriginRegistration() -> Path {
    return Path { path in
        path.move(to:CGPoint(x:0, y:10))
        path.addLine(to:CGPoint.zero)
        path.addLine(to:CGPoint(x:10, y:0))
    }
}

struct ImageBlocksAndText: View {
    private var recognizer: Recognizer
    
    init(
        trainedData: String,
        imgName: String
    ) {
        self.recognizer = Recognizer(trainedData: trainedData, imgName: imgName)
    }
    
    var body: some View {
        VStack {
            ZStack {
                Image(uiImage:recognizer.img).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                ForEach(0 ..< recognizer.blocks.count) { i in
                    Path { path in
                        path.addRect(self.recognizer.blocks[i].boundingBox)
                    }.stroke(Colors[i], lineWidth: 2)
                }
            }
            VStack {
                ForEach(0 ..< recognizer.blocks.count) { i in
                    ConfidentText(block: self.recognizer.blocks[i], i: i)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

var Colors = [Color.red, Color.yellow, Color.purple]

struct ConfidentText: View {
    private var s: String
    private var i: Int

    init(
        block: RecognizedBlock,
        i: Int
    ) {
        self.s = String(format:"%@: %.2f", block.text.trimmingCharacters(in: .whitespacesAndNewlines), block.confidence)
        self.i = i
    }
    
    var body: some View {
        Text(s)
            .border(Colors[self.i], width: 2)
            .frame(height: 30, alignment: .topLeading)
    }
}
