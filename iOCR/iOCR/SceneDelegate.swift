//
//  SceneDelegate.swift
//  iOCR
//
//  Created by Zach Young on 6/24/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import UIKit
import SwiftUI

import libtesseract

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        var jpn = Recognizer(imgName: "japanese", trainedDataName: "jpn", imgDPI: 144)
        var jpn_vert = Recognizer(imgName: "japanese_vert", trainedDataName: "jpn_vert", imgDPI: 144)
        var chi_trad_vert = Recognizer(imgName: "chinese_traditional_vert", trainedDataName: "chi_tra_vert")

        /// This sample image isn't so normal in its format, it's one run-on sentence wrapped around 8 ines.
        /// Something like a speech bubble from an English comic would probably be a much better sample.
        var eng = Recognizer(
            imgName: "english_left_just_square", trainedDataName: "eng",
            tessPSM: PSM_SINGLE_BLOCK, tessPIL: RIL_BLOCK
        )
        
        _ = jpn.getRecognizedRects()
        _ = jpn_vert.getRecognizedRects()
        _ = chi_trad_vert.getRecognizedRects()
        _ = eng.getRecognizedRects()
        
        defer {
            jpn.destroy()
            jpn_vert.destroy()
            chi_trad_vert.destroy()
            eng.destroy()
        }
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(
            jpn: jpn, jpn_vert: jpn_vert, chi_trad_vert: chi_trad_vert, eng: eng
        )
 
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

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

