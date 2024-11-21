//
//  NetworkManager.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import Foundation

public protocol NetworkManaging {
    func fetchSinglePokemon(query: String) async throws -> PokemonDetail
    func fetchMultiplePokemons() async throws -> PokemonList
}

public struct NetworkManager: NetworkManaging {
    typealias Urls = Constants.Urls
    
    public func fetchSinglePokemon(query: String) async throws -> PokemonDetail {
        
        guard let url = URL(string: query) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        
        let decodedData = try decoder.decode(PokemonDetail.self, from: data)

        return decodedData
    }
    
    public func fetchMultiplePokemons() async throws -> PokemonList {
        let url = Urls.baseURL + Urls.pokemonListURL
        
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        
        let decodedData = try decoder.decode(PokemonList.self, from: data)

        return decodedData
    }
}
