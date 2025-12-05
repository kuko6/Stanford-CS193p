//
//  EmojiMemoryGameView.swift -> Representing the View in MVVM
//  Memorize
//
//  Created by kuko on 16/06/2021.
//

import SwiftUI

/// Main View of the app consisting of **Buttons** and **cards** displayed on the screen
struct EmojiMemoryGameView: View {
    @ObservedObject // this ensures that, the view is rebuilt everytime viewModel, `game`, changes
    var game: EmojiMemoryGame
    
    @Namespace private var dealingNamespace
    
    @State private var dealtCards = Set<Int>()
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealtCards.insert(card.id)
    }
    
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealtCards.contains(card.id)
    }
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    private func calculateZIndex(of card: EmojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                // Title
                Text("Memorize!").bold().font(.title)
                if game.model.pairsLeft > 0 {
                    topBar.padding(2) // Theme Name and Score
                    cardBody
                } else {
                    Spacer()
                    winningScreen
                    Spacer()
                }
                Spacer()
                
                // Buttons
                HStack {
                    restart
                    Spacer()
                    shuffle
                }
                .foregroundColor(EmojiMemoryGame.currentTheme!.colour)
                .font(.largeTitle)
            }
            .padding(.horizontal)
            // deckBody is outside of the vstack, so its not taking space from the cards
            // essentially making them smaller, than they need to be
            deckBody
        }
    }
    
    // MARK: - Body components
    var topBar: some View {
        HStack {
            Text(EmojiMemoryGame.currentTheme!.name).bold().font(.title2)
            Spacer()
            Text("Score: \(game.model.score)").bold().font(.title2)
        }
    }
    
    var winningScreen: some View {
        VStack(alignment: .center) {
            Text("🎉 You Won! 🎉").bold().font(.title)
            Text("Final Score: \(game.model.score)").bold().font(.title)
        }
    }
    
    var cardBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: CardConstants.aspectRatio, content: { card in
            if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
                Color.clear // hides matched cards from the screen
            } else {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.scale.animation(Animation.easeInOut(duration: CardConstants.animationDuration)))
                    //.transition(AnyTransition.asymmetric(insertion: .identity, removal: .opacity))
                    .padding(4)
                    .zIndex(calculateZIndex(of: card))
                    .onTapGesture {
                        withAnimation {
                            game.choose(card)
                        }
                    }
            }
        })
    }
    
    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter(isUndealt)) { card in
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .onTapGesture {
            // add cards on the screen (this is still game initialization)
            for card in game.cards {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    // MARK: -- Buttons
    var restart: some View {
        Button(action: {
            withAnimation {
                dealtCards = []
                game.restartTheGame()
            }
        }, label: {
            Image(systemName: "restart.circle")
        })
    }
    
    // button with animation
    var shuffle: some View {
        Button(action: {
            withAnimation {
                game.shuffleTheCards()
            }
        }, label: {
            Image(systemName: "shuffle.circle")
        })
    }
    
    // contains "magic numbers" used in View
    struct CardConstants {
        static let animationDuration: Double = 0.75
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2.0
        
        static let aspectRatio: CGFloat = 2/3
        static let undealtHeight: CGFloat = 90
        static let undealtWidth: CGFloat = undealtHeight * aspectRatio
    }
    
}
    
    
/// **Struct** representing individual cards
/// and structure `body`, the shape of the card
struct CardView: View {
    // all these variables of type some View are combined variables,
    // which returns results of a statement,
    // so there is a hidden return at the beginning of each one of them
    let card: EmojiMemoryGame.Card
    
    @State private var animatedBonusRemaining: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            // ZStack or HStack is combined view of those elements
            // there is hidden return here
            // content: doesnt have to be here if there are no other arguments, like it is in VStack in ContentView
            ZStack(content: {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-animatedBonusRemaining)*360-90))
                            .onAppear {
                                animatedBonusRemaining = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0
                                }
                            }
                    } else {
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-card.bonusRemaining)*360-90))
                    }
                }
                .padding(DrawingConstant.piePadding)
                .opacity(DrawingConstant.pieOpacity)
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatCount(2, autoreverses: false))
                    .font(Font.system(size: DrawingConstant.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            })
            .cardify(isFaceUp: card.isFaceUp, isMatched: card.isMatched)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstant.fontSize / DrawingConstant.fontScale)
    }
    
    // contains "magic numbers" used in View 
    private struct DrawingConstant {
        static let fontScale: CGFloat = 0.7
        static let fontSize: CGFloat = 32
        
        static let piePadding: CGFloat = 3.5
        static let pieOpacity: Double = 0.5
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        //game.choose(game.cards.first!)
        
        EmojiMemoryGameView(game: game)
            .preferredColorScheme(.light)
        
        EmojiMemoryGameView(game: game)
            .preferredColorScheme(.dark)
    }
}

// so we can use the modifier with just .cardify(isFaceUp:isMatched:) instead of .modifier(Cardify(isFaceUp:isMatched:))
extension View {
    func cardify(isFaceUp: Bool, isMatched: Bool) -> some View {
        return self.modifier(Cardify(isFaceUp: isFaceUp, isMatched: isMatched))
    }
}
