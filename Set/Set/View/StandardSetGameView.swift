//
//  StandardSetGameView.swift -> View
//  Set
//
//  Created by kuko on 14/07/2021.
//

import SwiftUI

struct StandardSetGameView: View {
    @ObservedObject var game: StandardSetGame
    
    var body: some View {
        VStack {
            Text("Game Of Set").fontWeight(.bold).font(.title)
            Text("Score: \(game.model!.score)")
            AspectVGrid(items: game.cards, aspectRatio: 2/3, content: { card in
                CardView(card: card)
                    .padding(4)
                    .onTapGesture {
                        game.choose(card)
                    }
            })
            
            // MARK: - Buttons
            Spacer()
            HStack {
                addMoreCards
                Spacer()
                shuffle
                Spacer()
                restart
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    var addMoreCards: some View {
        Button(action: {
            game.dealMoreCards()
        }, label: {
            Text("Add")
        })
    }
    
    var restart: some View {
        Button(action: {
            game.restart()
        }, label: {
            Text("Restart")
        })
    }
    
    var shuffle: some View {
        Button(action: {
            game.shuffleCards()
        }, label: {
            Text("Shuffle")
        })
    }
    
}

struct CardView: View {
    let card: StandardSetGame.Card
    var body: some View {
        //if !card.isMatched || card.isMatched && card.isSelected {
            ZStack {
                let shape = RoundedRectangle(cornerRadius: DrawingConstant.cornerRadius)
                shape.stroke(lineWidth: DrawingConstant.lineWidth).fill()
                if card.isSelected {
                    shape.foregroundColor(.blue).opacity(0.6)
                } else if card.isMatched {
                    shape.foregroundColor(.green).opacity(0.6)
                }
                
                /*
                Oval(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: 1-90))
                    .foregroundColor(.orange)
                */
                VStack {
                    Text(card.content.shape)
                    Text(card.content.color)
                    Text(card.content.shading)
                    Text("\(card.content.number)")
                }
                .font(.footnote)
                
                if card.isMatched && !card.isSelected {
                    Text("Matched")
                }
            }
        //}
    }
    
    // contains "magic numbers" used in View
    private struct DrawingConstant {
        static let cornerRadius: CGFloat = 10
        static let lineWidth: CGFloat = 4
        static let fontScale: CGFloat = 0.8
        static let fontSizeMod: CGFloat = 15
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = StandardSetGame()
        
        StandardSetGameView(game: game)
    }
}
