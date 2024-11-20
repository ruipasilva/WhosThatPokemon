//
//  NetworkManager.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import Foundation

protocol NetworkManaging {
    func fetchData(query: Int) async throws -> Pokemon
}

public struct NetworkManager: NetworkManaging {
    typealias Urls = Constants.Urls
    
    func fetchData(query: Int) async throws -> Pokemon {
        let url = "\(Urls.baseURL)\(Urls.pokemonByIdURL)\(query)"
        
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        
        let decodedData = try decoder.decode(Pokemon.self, from: data)

        return decodedData
    }
    
    
}
