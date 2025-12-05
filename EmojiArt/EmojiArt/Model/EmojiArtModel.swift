//
//  EmojiArtModel.swift -> Model
//  EmojiArt
//
//  Created by kuko on 06/08/2021.
//

import Foundation

struct EmojiArtModel: Codable {
    var background = Background.blank
    var emojis: [Emoji] = []
    
    // x and y are offset from the center
    struct Emoji: Identifiable, Hashable, Codable {
        let id: Int
        
        let text: String
        var x: Int
        var y: Int
        var size: Int
        
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArtModel(json: data)
    }
    
    init() {}
    
    private var emojiIdentifier = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        emojiIdentifier += 1
        emojis.append(Emoji(id: emojiIdentifier, text: text, x: location.x, y: location.y, size: size))
    }
}
