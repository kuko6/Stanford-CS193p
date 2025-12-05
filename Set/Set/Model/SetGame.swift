//
//  SetGame.swift -> Model
//  Set
//
//  Created by kuko on 14/07/2021.
//

import Foundation

// **The Game of SET**
// 81 unique cards with same atributes, color, shape, shading and number of shapes (3 diamonds, 1 oval, etc.)
// player has to create a set
// set consists of 3 cards of either the same color, shape, shading or number,
// or player creates a set also when they all have different features
// at the beginng dealer deals 12 cards and player has to shout set and pick up the cards, dealer then adds to 12
// if there is no set, dealer will add another 3 cards,
// when there are no remaining cards or possible sets, the game ends

struct SetGame<CardContent: Equatable> {
    private var packOfCards: [Card]
    private let packSize: Int
    private(set) var cardsInPlay: [Card] = []
    private(set) var score = 0
    //private var numberOfCardsInPlay: Int
    private var nextCardIndexInPack = 0
    private var choosenCards: [Card] = []
    private var choosenCardIndices: [Int] = []
    
    init(numberOfCards: Int, startingNumberOfCards: Int, createContent: (Int) -> CardContent) {
        self.packOfCards = []
        self.packSize = numberOfCards
        
        for index in 0..<numberOfCards {
            self.packOfCards.append(Card(id: index, content: createContent(index)))
        }
        //self.packOfCards.shuffle()
        
        for _ in 0..<startingNumberOfCards {
            self.cardsInPlay.append(self.packOfCards[self.nextCardIndexInPack])
            self.nextCardIndexInPack += 1
        }
        /*
        for index in packOfCards.indices {
            if index != 0 && packOfCards[index-1].content != packOfCards[index].content {
                print("\n")
            }
            print("\(packOfCards[index])")
        }
        */
    }
    
    mutating func dealMoreCards(numberOfCardsToAdd: Int) {
        var removedCards = 0
        for index in cardsInPlay.indices {
            if cardsInPlay[index-removedCards].isMatched {
                cardsInPlay.remove(at: index-removedCards)
                removedCards += 1
            }
        }
        
        var numberOfCardsToAdd = numberOfCardsToAdd
        if cardsInPlay.count < 12 {
            numberOfCardsToAdd = 12 - cardsInPlay.count
        }
        
        for _ in 0..<numberOfCardsToAdd {
            if nextCardIndexInPack <= packSize-1 {
                cardsInPlay.append(packOfCards[nextCardIndexInPack])
                nextCardIndexInPack += 1
            } else {
                return
            }
        }
    }
    
    mutating func shuffleCards() {
        cardsInPlay.shuffle()
    }
    
    mutating func choose(_ card: Card) {
        if let choosenIndex = cardsInPlay.firstIndex(where: { cardInArray in cardInArray.id == card.id }),
           choosenCards.oneAndOnly(element: card), !card.isMatched {
            
            /*
            if choosenCards.count == 3 && cardsInPlay[choosenCards[0].id].isMatched {
                for index in choosenCards.indices { cardsInPlay[choosenCards[index].id].isSelected = false }
                choosenCards = []
            }*/
            
            if choosenCards.count != 3 {
                cardsInPlay[choosenIndex].isSelected = true
                choosenCards.append(cardsInPlay[choosenIndex])
                choosenCardIndices.append(choosenIndex)
            }
            if choosenCards.count == 3 {
                let matchingFeature = choosenCards[0].content == choosenCards[1].content && choosenCards[0].content == choosenCards[2].content
                    && choosenCards[1].content == choosenCards[2].content
                
                let everythingDifferent = choosenCards[0].content != choosenCards[1].content && choosenCards[0].content != choosenCards[2].content
                    && choosenCards[1].content != choosenCards[2].content
                
                if matchingFeature || everythingDifferent {
                    //print("match")
                    for index in choosenCards.indices {
                        cardsInPlay[choosenCardIndices[index]].isMatched = true
                        score += 1
                    }
                }
                for index in choosenCards.indices { cardsInPlay[choosenCardIndices[index]].isSelected = false }
                choosenCards = []
                choosenCardIndices = []
            }
        }
    }
    
    
    struct Card: Identifiable, Equatable {
        let id: Int
        
        let content: CardContent
        
        var isSelected = false
        var isMatched = false
    }
}
    
extension Array where Element: Equatable {
    func oneAndOnly(element: Element) -> Bool {
        if self.first(where: { elementInArray in element == elementInArray }) != nil {
            return false
        } else {
            return true
        }
    }
}
