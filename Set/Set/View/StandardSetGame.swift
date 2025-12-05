//
//  StandardSetGame.swift -> ViewModel
//  Set
//
//  Created by kuko on 14/07/2021.
//

import SwiftUI

class StandardSetGame: ObservableObject {
    typealias Card = SetGame<StandardCardContent>.Card
    
    private var cardContent: [StandardCardContent] = []
    
    @Published var model: SetGame<StandardCardContent>?
    var cards: Array<Card> {
        model!.cardsInPlay
    }
    
    init() {
        self.createCardContent()
        model = createSetGame()
    }
    
    func createSetGame() -> SetGame<StandardCardContent> {
        SetGame<StandardCardContent>(numberOfCards: 81, startingNumberOfCards: 12) { index in
            cardContent[index]
        }
    }
    
    func createCardContent() {
        let shapes = ["diamond", "squiggle", "oval"]
        let shading = ["solid", "striped", "open"]
        let colors = ["green", "blue", "red"]
        
        for shapeIndex in shapes.indices {
            for number in 1...3 {
                for shadingIndex in shading.indices {
                    for colorIndex in colors.indices {
                        cardContent.append(StandardCardContent(number: number, shape: shapes[shapeIndex], shading: shading[shadingIndex], color: colors[colorIndex]))
                    }
                }
            }
        }
    }
    
    // MARK: -Intents
    
    func dealMoreCards() {
        model?.dealMoreCards(numberOfCardsToAdd: 3)
    }
    
    func restart() {
        model = createSetGame()
    }
    
    func shuffleCards() {
        model?.shuffleCards()
    }
    
    func choose(_ card: Card) {
        model?.choose(card)
    }
}
