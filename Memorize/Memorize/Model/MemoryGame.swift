//
//  MemoryGame.swift -> Representing the Model in MVVM
//  Memorize
//
//  Created by kuko on 04/07/2021.
//

import Foundation

// MemoryGame is of type generic, so the game logic can be independent of the type of CardContent
// which could be either a String or maybe .png ...
// where statement ensures, that the generic type would be equatable
struct MemoryGame<CardContent> where CardContent: Equatable {
    private(set) var cards: [Card] // Read only, for other structs or classes
    
    private var faceUpCardIndex: Int? {
        // both get and set doesnt have to have the last '()' in this case
        get {
            cards.indices.filter({ index in cards[index].isFaceUp }).oneAndOnly
        }
        set {
            cards.indices.forEach({ index in cards[index].isFaceUp = (index == newValue) })
        }
    }
    
    private(set) var score: Int = 0
    private let bonus: Double = 10.0 // time bonus
    private let penalty: Int = 5 // penalty for quessing the same card wrong
    private(set) var pairsLeft: Int
    
    init(numberOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        self.cards = []
        self.pairsLeft = numberOfPairsOfCards
        
        for cardIndex in 0..<numberOfPairsOfCards {
            self.cards.append(Card(id: cardIndex*2, content: createCardContent(cardIndex)))
            self.cards.append(Card(id: cardIndex*2+1, content: createCardContent(cardIndex)))
        }
        self.cards.shuffle()
    }

    mutating func choose(_ card: Card) {
        // checks if choosen card exists in the array of cards and if it hasnt been turned up yet and matched
        if let choosenIndex = cards.firstIndex(where: {cardInArray in cardInArray.id == card.id}),
           !cards[choosenIndex].isFaceUp,
           !cards[choosenIndex].isMatched {
            if let potentialMatchIndex = faceUpCardIndex {
                if cards[choosenIndex].content == cards[potentialMatchIndex].content { // matched
                    cards[choosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    score += Int(bonus*cards[choosenIndex].bonusRemaining + bonus*cards[potentialMatchIndex].bonusRemaining)
                    pairsLeft -= 1
                } else if cards[choosenIndex].alreadySeen || cards[potentialMatchIndex].alreadySeen { // mismatched
                    score -= penalty
                }
                
                if !cards[potentialMatchIndex].alreadySeen {
                    cards[potentialMatchIndex].alreadySeen = true
                }
                if !cards[choosenIndex].alreadySeen {
                    cards[choosenIndex].alreadySeen = true
                }
                cards[choosenIndex].isFaceUp = true
            } else {
                faceUpCardIndex = choosenIndex
            }
        }
    }
    
    mutating func shuffle() {
        cards.shuffle()
    }
    
    // MARK: - Card Struct
    struct Card: Identifiable {
        let id: Int
        
        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        
        var isMatched = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        
        var alreadySeen = false
        let content: CardContent
        
        // MARK: - Bonus Time
        var bonusTimeLimit: TimeInterval = 6
        var lastFaceUpDate: Date?
        var pastFaceUpTime: TimeInterval = 0
        
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        
        // how much time left before the bonus opportunity runs out
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        
        // percentage of the bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            self.lastFaceUpDate = nil
        }
    }
}

extension Array {
    var oneAndOnly: Element? {
        if self.count == 1 {
            return self.first
        } else {
            return nil
        }
    }
}
