//
//  GameViewViewModel.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import Foundation

public final class GameViewViewModel: ObservableObject {
    @Published public var gameLoadingState: GameLoadingState = .inactive
    @Published public var isGameStarted = false
    @Published public var isAnswerPicked = false
    @Published public var isAnswerCorrect = false
    @Published public var selectedAnswer = ""
    @Published public var currentScore = 0
    
    
    public var pokemonDetail: PokemonDetail?
    public var allPokemons = [Pokemon]()
    public var firstFourRandomPokemons = [Pokemon]()
    
    var networkManager: NetworkManaging
    
    
    init(networkManager: NetworkManaging = NetworkManager()) {
        self.networkManager = networkManager
        
        Task {
            await getAllPokemons()
        }
    }
    
    @MainActor
    public func getAllPokemons() async {
        do {
            let pokemons = try await networkManager.fetchMultiplePokemons()
            
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
    public func getFourPossibleAnswers() async {
        let pokemonShuffled = allPokemons.shuffled()
        
        firstFourRandomPokemons = Array(pokemonShuffled.prefix(upTo: 4))
        
        guard let randomPokemonUrl = firstFourRandomPokemons.randomElement()?.url else { return }
        
        await getPokemonDetail(with: randomPokemonUrl)
        
        isGameStarted = true
    }
    
    @MainActor
    private func getPokemonDetail(with url: String) async {
        gameLoadingState = .loading
        do {
            let pokemonDetail = try await networkManager.fetchSinglePokemon(query: url)
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
    
    public func selectAnswer(_ pokemon: Pokemon, topScore: inout Int) {
        isAnswerPicked = true
        isAnswerCorrect = true
        selectedAnswer = pokemon.name
        if pokemon.name == pokemonDetail?.name {
            currentScore += 1
            if currentScore > topScore {
                topScore = currentScore
            }
        }
    }
    
    public func leaveGame() {
        isAnswerCorrect = false
        isAnswerPicked = false
        isGameStarted = false
        currentScore = 0
        gameLoadingState = .inactive
    }
    
    public func reset(score: inout Int) {
        score = 0
    }
    
    @MainActor
    public func nextRound() async {
        isAnswerCorrect = false
        isAnswerPicked = false
        await getFourPossibleAnswers()
    }
    
    public func checkIfSameName(pokemon: Pokemon) -> Bool {
        pokemon.name == pokemonDetail?.name
    }
}
