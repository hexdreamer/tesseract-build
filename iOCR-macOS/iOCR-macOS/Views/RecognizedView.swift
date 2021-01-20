//
//  RecognizedView.swift
//  iOCR
//
//  Created by Zach Young on 9/16/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import CoreText
import SwiftUI
import hexdreamsCocoa

private let RECT_COLORS = [Color.red, Color.orange, Color.purple]

struct RecognizedView: View {
    public let caption: String
    public let recognizer: Recognizer

    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 0, alignment: .top),
            GridItem(.flexible(), spacing: 0, alignment: .top),
            GridItem(.flexible(), spacing: 0, alignment: .top),
        ]
        let recRects = recognizer.getRecognizedRects()

        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.black)

            VStack {
                Text(caption)
                    .foregroundColor(Color.gray)
                    .font(.title)
                    .padding(.top, 5.0)
                
                GeometryReader { geo in
                    ImageAndRects(image: recognizer.uiImage, recRects: recRects, parentViewSize: geo.size)
                }
                
                LazyVGrid(columns: columns, spacing: 10) {
                    
                    Header(text: Text("Box"))
                    Header(text: Text("Text"))
                    Header(text: Text("Confidence"))
                    
                    ForEach(recRects, id: \.id) {rect in
                        Row(rect: rect, idx: recRects.firstIndex(of: rect)!)
                    }
                } // LazyVGrid
                .padding(.bottom, 10.0)

            } // VStack

        } // ZStack
        .frame(width: 500, height: 650)
    }
}

struct ImageAndRects: View {
    let image: NSImage
    let recRects: [RecognizedRectangle]
    let parentViewSize: CGSize
    
    private var imageViewTransform: CGAffineTransform {
        let outerRect = CGRect(size: self.parentViewSize)
        var myRect = CGRect(size: self.image.size)
        
        myRect = myRect.fit(rect: outerRect)
        let scaleFactor = myRect.width / self.image.size.width
        
        var transform = CGAffineTransform.identity
        
        transform = transform.translatedBy(x: myRect.minX, y: myRect.minY)
        transform = transform.scaledBy(x: scaleFactor, y: scaleFactor)
        
        return transform
    }
    
    var body: some View {
        let transform = imageViewTransform
        ZStack {
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .fill(Color(red: 0.85, green: 0.85, blue: 0.85, opacity: 1.0))
                .frame(maxWidth: parentViewSize.width-15, maxHeight: parentViewSize.height-15)

            Image(nsImage: self.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: parentViewSize.width-25, maxHeight: parentViewSize.height-25)

            ForEach(recRects, id: \.id) { rect in
                Path { path in
                    path.addRect(rect.boundingBox.applying(transform))
                }
                .stroke(RECT_COLORS[recRects.firstIndex(of: rect)!], lineWidth: 4)
            } // ForEach
            
        } // ZStack
    }
}

struct Header: View {
    let text: Text

    var body: some View {
        return self.text
            .font(.title)
            .foregroundColor(Color.gray)
    }
}

struct Row: View {
    let rect: RecognizedRectangle
    let idx: Int

    var body: some View {
        Rectangle()
            .stroke(RECT_COLORS[idx], lineWidth: 6)
            .frame(width: 30, height: 30, alignment: .topLeading)
        Text(trimText(rect.text))
            .font(.title)
        Text(String(format: "%.0f%%", rect.confidence))
            .font(.title)
    }
    
    /// Get rid of newlines; truncate at 40 chars (for long-form English example)
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
}

// MARK: Preview
import libtesseract

struct RecognizedView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
