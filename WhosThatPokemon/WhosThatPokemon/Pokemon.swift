//
//  Pokemon.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import Foundation

//public struct Pokemon: Decodable {
//    let name: String
//    let url: String
//}

public struct Pokemon: Codable {
    let name: String
    let sprites: Sprites
}

public struct Sprites: Codable {
    
    enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    var frontDefault: String
}


