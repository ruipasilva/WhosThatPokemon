//
//  GameViewViewModel.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import Foundation

public final class GameViewViewModel: ObservableObject {
    @Published public var gameLoadingState: GameLoadingState = .inactive
    @Published public var answer: String = ""
    @Published public var isAnswerPicked = false
    @Published public var isAnsweredRevealed = false
    @Published public var isAnswerCorrect: Bool = false
    
    public var pokemonDetail: PokemonDetail?
    public var allPokemons = [Pokemon]()
    public var fourPossibleAnswers = [Pokemon]()
    
    let networkManager: NetworkManaging
    
    
    init(networkManager: NetworkManaging = NetworkManager()) {
        self.networkManager = networkManager
        
        Task {
            await getAllPokemons()
        }
    }
    
    public func getAllPokemons() async {
        do {
            let pokemons = try await networkManager.fetchMultiple()
            
            allPokemons = pokemons.results
        
        } catch let error as NetworkError {
            switch error {
            case .invalidURL, .invalidData, .invalidResponse, .unableToComplete:
                gameLoadingState = .failed(error: error.title)
            }
        } catch {
            gameLoadingState = .failed(error: error.localizedDescription)
        }
    }
    
    @MainActor
    private func getPokemon(with url: String) async {
        gameLoadingState = .loading
        do {
            let pokemonDetail = try await networkManager.fetchSingle(query: url)
            self.pokemonDetail = pokemonDetail
            gameLoadingState = .imageLoaded(pokemon: pokemonDetail)
        } catch let error as NetworkError {
            switch error {
            case .invalidURL, .invalidData, .invalidResponse, .unableToComplete:
                gameLoadingState = .failed(error: error.title)
            }
        } catch {
            gameLoadingState = .failed(error: error.localizedDescription)
        }
    }
    
   
  
    @MainActor
    public func getFourPossibleAnswers() async {
        let pokemonShuffled = allPokemons.shuffled()
        
        fourPossibleAnswers = Array(pokemonShuffled.prefix(upTo: 4))
        
        guard let randomPokemonUrl = fourPossibleAnswers.randomElement()?.url else { return }
        
        let randomPokemon = randomPokemonUrl
        
        await getPokemon(with: randomPokemon)
    }
}
