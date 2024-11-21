//
//  MockPokemons.swift
//  WhosThatPokemonTests
//
//  Created by Rui Silva on 21/11/2024.
//

import Foundation
@testable import WhosThatPokemon

struct MockPokemons {
    static var allPokemons: [Pokemon] = [Pokemon(name: "Bulbasaur",
                                                 url: "https://pokeapi.co/api/v2/pokemon/1/"),
                                         Pokemon(name: "Charmander",
                                                 url: "https://pokeapi.co/api/v2/pokemon/4/"),
                                         Pokemon(name: "Squirtle",
                                                 url: "https://pokeapi.co/api/v2/pokemon/7/"),
                                         Pokemon(name: "Pikachu",
                                                 url: "https://pokeapi.co/api/v2/pokemon/25/")
    ]
    
    static let singlePokemon: Pokemon = allPokemons.first!
    
    static let expectedSprites = Sprites(frontDefault: "test.png")
    static let singlePokemonDetail = PokemonDetail(name: "Bulbasaur", sprites: expectedSprites)
}
