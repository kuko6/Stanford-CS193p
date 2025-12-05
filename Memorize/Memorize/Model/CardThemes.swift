//
//  CardThemes.swift -> Also representing Model
//  Memorize
//
//  Created by kuko on 07/07/2021.
//

import Foundation

struct EmojiTheme {
    var name: String
    var numberOfPairs: Int
    var randomNumberOfPairs: Bool = false
    var colour: String
    var emojis: [String]
    
    init(name: String, numberOfPairs: Int, colour: String, emojis: [String]) {
        self.name = name
        self.numberOfPairs = numberOfPairs
        self.colour = colour
        self.emojis = emojis
    }
    
    init(name: String, colour: String, emojis: [String]) {
        self.name = name
        self.numberOfPairs = emojis.count
        self.colour = colour
        self.emojis = emojis
    }
    
    init(name: String, randomNumberOfPairs: Bool, colour: String, emojis: [String]) {
        self.name = name
        self.randomNumberOfPairs = randomNumberOfPairs
        self.numberOfPairs = emojis.count
        self.colour = colour
        self.emojis = emojis
    }
}

let emojiThemes = [
    EmojiTheme(name: "Animals", numberOfPairs: 4, colour: "green", emojis: ["🦧", "🐒", "🦍", "🦥", "🐛", "🐝", "🐍", "🐉", "🦐", "🦎", "🐞", "🦑", "🦦", "🦜"]),
    EmojiTheme(name: "Faces", numberOfPairs: 6, colour: "blue", emojis: ["😆", "😚", "😎", "🥸", "🤠", "🤯", "😳", "🥺", "🥰", "🥳"]),
    EmojiTheme(name: "Food", numberOfPairs: 10, colour: "red", emojis: ["🍎", "🍑", "🥭", "🍳", "🍕", "🍔", "🥪", "🍖", "🍰", "🍩", "🍣", "🌮"]),
    EmojiTheme(name: "Halloween", numberOfPairs: 3, colour: "orange", emojis: ["👻", "🕷", "🎃", "🦇", "💀"]),
    EmojiTheme(name: "Sports", colour: "yellow", emojis: ["⚽️", "🏀", "🎾", "⚾️", "⛷"]),
    EmojiTheme(name: "Vehicles", randomNumberOfPairs: true, colour: "cyan", emojis: ["✈️", "🚗", "🚚", "🏎", "🚀", "🚁", "🚞", "🚲", "🛵", "🚤"])
]
