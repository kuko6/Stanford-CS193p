//
//  Cardify.swift -> View modifier
//  Memorize
//
//  Created by kuko on 18/07/2021.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    @Environment(\.colorScheme) var colorScheme
    
    var isMatched: Bool

    var rotation: Double // degrees
    var animatableData: Double { // this basically ensures, that the opacity in vstack wont be animated
        get { rotation }
        set { rotation = newValue }
    }
    
    init(isFaceUp: Bool, isMatched: Bool) {
        self.rotation = isFaceUp ? 0 : 180
        self.isMatched = isMatched
    }
    
    func body(content: Content) -> some View {
        ZStack(content: {
            let shape = RoundedRectangle(cornerRadius: DrawingConstant.cornerRadius)
            
            if rotation < 90 {
                shape.stroke(lineWidth: DrawingConstant.lineWidth)
                if colorScheme == .dark {
                    shape.fill().foregroundColor(.black)
                } else {
                    shape.fill().foregroundColor(.white)
                }
            } else {
                shape.fill(EmojiMemoryGame.currentTheme!.colour)
            }
            content.opacity(rotation < 90 ? 1 : 0)
            //content.opacity(isFaceUp ? 1 : 0)
        })
        .rotation3DEffect(Angle.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .foregroundColor(EmojiMemoryGame.currentTheme!.colour)
    }
    
    // contains "magic numbers" used in View
    private struct DrawingConstant {
        static let cornerRadius: CGFloat = 15
        static let lineWidth: CGFloat = 5
    }
}
