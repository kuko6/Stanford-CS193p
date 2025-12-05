//
//  EmojiArtModel.Background.swift -> Extension of the Model, to make the code more clean :)
//  EmojiArt
//
//  Created by kuko on 06/08/2021.
//

import Foundation

// extension for EmojiArtModel, that adds Background, technically could be in the same file as EmojiArtModel
extension EmojiArtModel {
    enum Background: Equatable, Codable {
        case blank
        case url(URL)
        case imageData(Data)
        
        // Important for protocol Codable
        // try could return an error, try? will instead return nil
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let url = try? container.decode(URL.self, forKey: .url) {
                self = .url(url)
            } else if let imageData = try? container.decode(Data.self, forKey: .imageData) {
                self = .imageData(imageData)
            } else {
                self = .blank
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case url = "theURL"
            case imageData
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self) // .self means, thats including the type itself
            
            switch self {
            case .url(let url):
                try container.encode(url, forKey: .url)
            case .imageData(let data):
                try container.encode(data, forKey: .imageData)
            case .blank:
                break
            }
        }
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
