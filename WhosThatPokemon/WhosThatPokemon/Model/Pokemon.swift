//
//  Pokemon.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import Foundation

public struct PokemonDetail: Codable {
    let name: String
    let sprites: Sprites
}

public struct Sprites: Codable {
    var frontDefault: String
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

public struct PokemonList: Codable {
    var results: [Pokemon]
}

public struct Pokemon: Codable {
    let name: String
    let url: String
}


