//
//  MemorizeApp.swift -> Sort of a Main file for our app
//  Memorize
//
//  Created by kuko on 16/06/2021.
//

import SwiftUI

@main
struct MemorizeApp: App {
    let game = EmojiMemoryGame()
    
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(game: game) // main scene
        }
    }
}
