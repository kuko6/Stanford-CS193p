//
//  EmojiMemoryGame.swift -> Representing the ViewModel in MVVM
//  Memorize
//
//  Created by kuko on 04/07/2021.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    
    private(set) static var currentTheme: CardTheme?
    
    /// struct `MemoryGame` takes numberOfPairsOfCards and function to create CardContent, in this case its a shortly written closure
    /// this method has to be static so it can work with other static properties
    private static func createMemoryGame() -> MemoryGame<String> {
        currentTheme = CardTheme(emojiTheme: emojiThemes[Int.random(in: 0..<emojiThemes.count)])
                
        return MemoryGame<String>(numberOfPairsOfCards: currentTheme!.numberOfPairs) { pairIndex in
            currentTheme!.emojis[pairIndex]
        }
    }
    
    @Published
    private(set) var model = createMemoryGame()
    
    // var objectWillChange: ObservableObjectPublisher is implemented for us, so it doesnt have to be here
    
    var cards: Array<Card> {
        model.cards
    }
    
    struct CardTheme {
        var name: String
        var emojis: [String] = []
        var numberOfPairs: Int
        var colour: Color
        
        init(emojiTheme: EmojiTheme) {
            self.name = emojiTheme.name
            
            // checks whether there are any duplicated emojis
            for emoji in emojiTheme.emojis.shuffled() {
                if !self.emojis.contains(emoji) {
                    self.emojis.append(emoji)
                }
            }
            
            // if the number of pairs should be a random number or
            // if the number of pairs was bigger then the actual number of emojis
            if emojiTheme.randomNumberOfPairs {
                self.numberOfPairs = Int.random(in: 2...self.emojis.count)
            } else if emojiTheme.numberOfPairs > emojiTheme.emojis.count {
                self.numberOfPairs = self.emojis.count
            } else {
                self.numberOfPairs = emojiTheme.numberOfPairs
            }
            
            switch emojiTheme.colour {
            case "green":
                self.colour = Color.green
            case "blue":
                self.colour = Color.blue
            case "red":
                self.colour = Color.red
            case "orange":
                self.colour = Color.orange
            case "yellow":
                self.colour = Color.yellow
            default:
                self.colour = Color.purple
            }
        }
    }
    
    // MARK: - Intent(s)
    
    func choose(_ card: Card) {
        // objectWillChange.send() this doesnt have to be here aswell thanks to the @Published near var model
        model.choose(card)
    }
    
    func restartTheGame() {
        model = EmojiMemoryGame.createMemoryGame()
    }
    
    func shuffleTheCards() {
        model.shuffle()
    }
}
