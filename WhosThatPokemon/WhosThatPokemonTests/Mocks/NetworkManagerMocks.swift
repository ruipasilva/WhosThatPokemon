//
//  NetworkManagerMocks.swift
//  WhosThatPokemonTests
//
//  Created by Rui Silva on 21/11/2024.
//

import Foundation
@testable import WhosThatPokemon

class NetworkManagerMock: NetworkManaging {
    var shouldReturnError = false
    var pokemonDetail: PokemonDetail?
    var pokemonList: PokemonList?
    
    
    public func fetchSinglePokemon(query: String) async throws -> PokemonDetail {
        if shouldReturnError {
            throw NetworkError.unableToComplete
        } else if let pokemonDetail = pokemonDetail {
            return pokemonDetail
        } else {
            throw NetworkError.invalidData
        }
    }
    
    func fetchMultiplePokemons() async throws -> PokemonList {
        if shouldReturnError {
            throw NetworkError.unableToComplete
        } else if let pokemonList = pokemonList {
            return pokemonList
        } else {
            throw NetworkError.invalidData
        }
    }
    
    
}
