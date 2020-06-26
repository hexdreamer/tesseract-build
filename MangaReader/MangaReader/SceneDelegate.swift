//
//  SceneDelegate.swift
//  MangaReader
//
//  Created by Zach Young on 6/4/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import UIKit
import SwiftUI
//import libleptonica
//import libtesseract

//typealias Pix = UnsafeMutablePointer<PIX>?
//typealias TessBaseAPI = OpaquePointer

//private let tesseract: TessBaseAPI = TessBaseAPICreate()

//enum MyError: Error {
//    case runtimeError(String)
//    case unableToExtractTextFromImage
//    case unableToInitializeTesseract(String)
//}
//
//public protocol LanguageModelDataSource {
//  var pathToTrainedData: String { get }
//}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let image = getImage(named: "Jeff")
  
//        guard case let .success(extractedTxt) = performOCR(on: image) else { return }
        let contentView = ContentView(
            cgImage: cgImage(uiImage:image),
            uiImage: image,
            text: "")

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    private func getImage(named name: String) -> UIImage {
      UIImage(named: name, in: Bundle(for: self.classForCoder), compatibleWith: nil)!
    }
    
//    private func performOCR(on: UIImage) -> Result<String, MyError> {
//        let pix = try! createPix(from: on)
//
//        let engineMode = UInt32(1)
//        let languageString = "eng"
//
//        let path = Bundle.main.path(forResource: "tessdata", ofType: nil, inDirectory: "share")
//
//        setenv("TESSDATA_PREFIX", path, 1)
//        guard TessBaseAPIInit2(tesseract,
//                               path,
//                               languageString,
//                               TessOcrEngineMode(rawValue: engineMode)) == 0
//            else { return .failure(MyError.unableToInitializeTesseract("Initialization error")) }
//
//        TessBaseAPISetImage2(tesseract, pix)
//        print(TessBaseAPIGetSourceYResolution(tesseract))
//        guard let extractedTxt = TessBaseAPIGetUTF8Text(tesseract)
//            else { return .failure(MyError.unableToExtractTextFromImage) }
//
//        return .success(String(cString: extractedTxt))
//    }
//
//    private func createPix(from image: UIImage) throws -> Pix {
//        guard let data = image.pngData() else { throw MyError.runtimeError("oops") }
//        let rawPointer = (data as NSData).bytes
//        let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)
//        return pixReadMem(uint8Pointer, data.count)
//    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

