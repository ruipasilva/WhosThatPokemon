//
//  GameViewViewModel.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import Foundation

public final class GameViewViewModel: ObservableObject {
    @Published public var gameLoadingState: GameLoadingState = .inactive
    
    let networkManager: NetworkManaging
    
    
    init(networkManager: NetworkManaging = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    @MainActor
    public func getPokemon(with id: Int) async {
        gameLoadingState = .loading
        do {
            let pokemon = try await networkManager.fetchData(query: id)
            gameLoadingState = .imageReveiled(pokemon: pokemon)
        } catch let error as NetworkError {
            switch error {
            case .invalidURL, .invalidData, .invalidResponse, .unableToComplete:
                gameLoadingState = .failed(error: error.title)
            }
        } catch {
            gameLoadingState = .failed(error: error.localizedDescription)
        }
    }
    
    public func generateRandomPokemonId() -> Int {
        let randomNumber = Int.random(in: 1...151)
        return randomNumber
    }
}
