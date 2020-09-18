//
//  RecognizedView.swift
//  iOCR
//
//  Created by Zach Young on 9/16/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import SwiftUI


struct RecognizedView: View {
    let recognizer: Recognizer
    let colors = [Color.red, Color.yellow, Color.purple]

    var body: some View {
        let columns = [
            GridItem(.flexible(), alignment: .top),
            GridItem(.flexible(), alignment: .top),
            GridItem(.flexible(), alignment: .top),
        ]
        let recRects = recognizer.getRecognizedRects()
        VStack {
            GeometryReader { geo in
                ZStack {
                    Image(uiImage: recognizer.uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                                        
                    ForEach(recRects, id: \.id) { rect in
                        Path { path in
                            let transform = getImageViewTransform(imgViewGeoProxy: geo)
                            path.addRect(rect.boundingBox.applying(transform))
                        }
                        .stroke(colors[recRects.firstIndex(of: rect)!], lineWidth: 4)
                    }
                } // ZStack
            } // GeometryReader

            LazyVGrid(columns: columns, spacing: 10) {

                Text("Box").font(.title2)
                Text("Text").font(.title2)
                Text("Confidence").font(.title2)

                ForEach(recRects, id: \.id) {rect in
                    Rectangle()
                        .stroke(colors[recRects.firstIndex(of: rect)!], lineWidth: 6)
                        .frame(width: 30, height: 30, alignment: .topLeading)
                    Text(trimText(rect.text))
                        .font(.system(size: 30))
                    Text(String(format: "%.0f%%", rect.confidence))
                        .font(.system(size: 20))
                }
            }
            .padding()

        } // VStack
        .border(Color.orange, width: 4)
        .frame(width:512, height:661)
    }
    
    private func trimText(_ text: String) -> String {
        let trimLen = 40
        var s = text
        s = s.trimmingCharacters(in: .whitespacesAndNewlines)
   
        if s.count < trimLen {
            return s
        }
        
        let start = s.startIndex
        let end = s.index(start, offsetBy: trimLen)
        let range = start...end
        
        return String(s[range])
    }
   
    private func getImageViewTransform(imgViewGeoProxy: GeometryProxy) -> CGAffineTransform {
        let img = self.recognizer.uiImage
        let outerRect = CGRect(size: imgViewGeoProxy.size)
        var myRect = CGRect(size: img.size)
        
        myRect = myRect.fit(rect: outerRect)
        let scaleFactor = myRect.width / img.size.width
        
        var transform = CGAffineTransform.identity
        
        transform = transform.translatedBy(x: myRect.minX, y: myRect.minY)
        transform = transform.scaledBy(x: scaleFactor, y: scaleFactor)
        
        return transform
    }
}

import libtesseract

struct RecognizedView_Previews: PreviewProvider {
    static var previews: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        LazyVGrid(columns: columns) {
            RecognizedView(
                recognizer: Recognizer(imgName: "japanese", trainedDataName: "jpn", imgDPI: 144)
            )
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
