//
//  SetApp.swift
//  Set
//
//  Created by kuko on 14/07/2021.
//

import SwiftUI

@main
struct SetApp: App {
    let game = StandardSetGame()
    var body: some Scene {
        WindowGroup {
            StandardSetGameView(game: game)
        }
    }
}
