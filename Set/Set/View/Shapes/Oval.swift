//
//  Oval.swift
//  Set
//
//  Created by kuko on 15/07/2021.
//

import SwiftUI

struct Oval: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool = false
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let start = CGPoint(
            x: rect.maxX,
            y: rect.maxY
        )
        
        var p = Path()
        p.move(to: start)
        p.addLine(to: start)
        p.addLine(to: center)
        
        return p
    }
    
}
