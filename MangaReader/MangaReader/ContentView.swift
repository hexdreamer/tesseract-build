//
//  ContentView.swift
//  MangaReader
//
//  Created by Zach Young on 6/4/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import SwiftUI
import libleptonica
import libtesseract

typealias Pix = UnsafeMutablePointer<PIX>?
typealias TessBaseAPI = OpaquePointer

private let tesseract: TessBaseAPI = TessBaseAPICreate()

enum MyError: Error {
    case runtimeError(String)
    case unableToExtractTextFromImage
    case unableToInitializeTesseract(String)
    case unableToRetrieveIterator
}

public protocol LanguageModelDataSource {
  var pathToTrainedData: String { get }
}

struct ContentView: View {
    var cgImage:CGImage;
    var uiImage:UIImage;
    var text:String;
    
    var body: some View {
        let extractedTxt = performOCR(on: self.uiImage)
        print(extractedTxt)
        return VStack(alignment: .leading) {
            ZStack {
                Image(uiImage:self.uiImage)
                    .resizable()
                    .aspectRatio(contentMode:.fit)
                    .clipShape(RoundedRectangle(cornerRadius:20, style:.circular))
                GeometryReader { geometry in
                    Path { path in
                        path.move(to:CGPoint(x:0, y:10))
                        //                    path.addLine(to:<#T##CGPoint#>.zero)
                        path.addLine(to:CGPoint.zero)
                        path.addLine(to:CGPoint(x:10, y:0))
                    }.stroke(Color.red, lineWidth: 4)
                    
                    //                drawGrid(size: geometry.size, spacing: 20).stroke(Color.purple, lineWidth:1)
                    //                drawGrid(size: geometry.size, spacing: 100).stroke(Color.red, lineWidth:2)
                    //                drawFirstPanelRect().stroke(Color.yellow, lineWidth: 3)
                }
            }
            Text(extractedTxt)
        }
    }
}

private func drawGrid(size:CGSize, spacing:Int) -> Path {
    return Path { path in
        let gridWidthSteps = size.width/CGFloat(spacing)
        let gridHeightSteps = size.height/CGFloat(spacing)
        
        for i in 1...Int(gridWidthSteps) - 1
        {
            let start = CGPoint(x: CGFloat(i * spacing), y:0)
            let end = CGPoint(x: CGFloat(i * spacing), y:size.height)
            path.move(to: start)
            path.addLine(to: end)
        }
        
        for i in 1...Int(gridHeightSteps) - 1
        {
            let start = CGPoint(x:0, y: CGFloat(i * spacing))
            let end = CGPoint(x:size.width, y: CGFloat(i * spacing))
            path.move(to: start)
            path.addLine(to: end)
        }
    }
}

private func drawFirstPanelRect() -> Path {
    return Path { path in
        let imageRect = CGRect(
            origin: CGPoint(x:70,y:120),
            size:CGSize(width:CGFloat(270), height:CGFloat(500)))
        path.addRect(imageRect)
    }
}

enum ResultIteratorLevel: TessPageIteratorLevel.RawValue {
  /// RIL_BLOCK
  case block
  /// RIL_PARA
  case paragraph
  /// RIL_TEXTLINE
  case textline
  /// RIL_WORD
  case word
  /// RIL_SYMBOL
  case symbol

  public var tesseractLevel: TessPageIteratorLevel {
    return TessPageIteratorLevel(rawValue: self.rawValue)
  }
}

struct RecognizedBlock {
  public var text: String
  public var boundingBox: CGRect
  public var confidence: Float
}

private func performOCR(on: UIImage) -> Result<String, MyError> {
    let pix = try! createPix(from: on)
    
    let engineMode = UInt32(1)
    let languageString = "jpn_vert"
    
    let path = Bundle.main.path(forResource: "tessdata", ofType: nil, inDirectory: "share")

    setenv("TESSDATA_PREFIX", path, 1)
    guard TessBaseAPIInit2(tesseract,
                           path,
                           languageString,
                           TessOcrEngineMode(rawValue: engineMode)) == 0
        else { return .failure(MyError.unableToInitializeTesseract("Initialization error")) }
    
    TessBaseAPISetImage2(tesseract, pix)
    print(TessBaseAPIGetSourceYResolution(tesseract))
    guard let extractedTxt = TessBaseAPIGetUTF8Text(tesseract)
        else { return .failure(MyError.unableToExtractTextFromImage) }
    
    return .success(String(cString: extractedTxt))
}

private func createPix(from image: UIImage) throws -> Pix {
    guard let data = image.pngData() else { throw MyError.runtimeError("oops") }
    let rawPointer = (data as NSData).bytes
    let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)
    return pixReadMem(uint8Pointer, data.count)
}

private func block(from iterator: OpaquePointer, for level: TessPageIteratorLevel) -> RecognizedBlock? {
  guard let cString = TessResultIteratorGetUTF8Text(iterator, level) else { return nil }
  defer { TessDeleteText(cString) }

  let boundingBox = makeBoundingBox(from: iterator, for: level)
  let text = String(cString: cString)
  let rect = boundingBox.cgRect
  let confidence = TessResultIteratorConfidence(iterator, level)

  return RecognizedBlock(text: text, boundingBox: rect, confidence: confidence)
}

private func makeBoundingBox(from iterator: OpaquePointer, for level: TessPageIteratorLevel) -> BoundingBox {
  var box = BoundingBox()
  TessPageIteratorBoundingBox(iterator, level, &box.originX, &box.originY, &box.widthOffset, &box.heightOffset)
  return box
}

func recognizedBlocks(for level: ResultIteratorLevel) -> Result<[RecognizedBlock], MyError> {
  guard let resultIterator = TessBaseAPIGetIterator(tesseract)
    else { return .failure(MyError.unableToRetrieveIterator) }

  defer { TessPageIteratorDelete(resultIterator)}

  var results = [RecognizedBlock]()

  repeat {
    if let block = block(from: resultIterator, for: level.tesseractLevel) {
      results.append(block)
    }
  } while (TessPageIteratorNext(resultIterator, level.tesseractLevel) > 0)

  return .success(results)
}

struct BoundingBox {
  var originX: Int32 = 0
  var originY: Int32 = 0
  var widthOffset: Int32 = 0
  var heightOffset: Int32 = 0

  var cgRect: CGRect {
    return CGRect(
      x: .init(originX),
      y: .init(originY),
      width: .init(widthOffset - originX),
      height: .init(heightOffset - originY)
    )
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let image = UIImage(named: "Cropped")!
        return ContentView(
            cgImage:cgImage(uiImage:image),
            uiImage:image,
            text: "")
    }
}
