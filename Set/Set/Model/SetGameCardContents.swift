//
//  SetGameCardContents.swift
//  Set
//
//  Created by kuko on 15/07/2021.
//

import Foundation

struct StandardCardContent: Equatable {
    let number: Int
    let shape: String
    let shading: String
    let color: String
    
    static func ==(_ lhs: StandardCardContent, _ rhs: StandardCardContent) -> Bool {
        return lhs.number == rhs.number || lhs.color == rhs.color || lhs.shape == rhs.shape || lhs.shading == rhs.shading
    }
}
