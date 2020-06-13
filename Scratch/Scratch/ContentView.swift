//
//  ContentView.swift
//  Scratch
//
//  Created by Zach Young on 6/13/20.
//  Copyright © 2020 Zach Young. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private func createPix(from image: UIImage) -> Pix {
    let data = image.pngData()!
    let rawPointer = (data as NSData).bytes
    let uint8Pointer = rawPointer.assumingMemoryBound(to: UInt8.self)
    return pixReadMem(uint8Pointer, data.count)
}
