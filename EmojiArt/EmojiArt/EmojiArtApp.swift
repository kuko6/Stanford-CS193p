//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by kuko on 06/08/2021.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    let paletteStore = PaletterStore(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
