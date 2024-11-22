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
        gameLoadingState = .loading
        do {
            let pokemons = try await networkManager.fetchMultiplePokemons()
            
            allPokemons = pokemons.results
        
            gameLoadingState = .inactive
        } catch let networkError as NetworkError {
            handleError(networkError: networkError)
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
    }
    
    @MainActor
    private func getPokemonDetail(with url: String) async {
        gameLoadingState = .loading
        do {
            let pokemonDetail = try await networkManager.fetchSinglePokemon(query: url)
            self.pokemonDetail = pokemonDetail
            gameLoadingState = .imageLoaded(pokemon: pokemonDetail)
            isGameStarted = true
        } catch let networkError as NetworkError {
            handleError(networkError: networkError)
        } catch {
            gameLoadingState = .failed(error: error.localizedDescription)
        }
    }
    
    private func handleError(networkError: NetworkError) {
        switch networkError {
        case .invalidURL, .invalidData, .invalidResponse, .unableToComplete:
            gameLoadingState = .failed(error: networkError.title)
        }
    }
    
    public func selectAnswer(_ pokemon: Pokemon, topScore: inout Int) {
        isAnswerPicked = true
        selectedAnswer = pokemon.name
        if pokemon.name == pokemonDetail?.name {
            handleScore(topScore: &topScore)
        }
    }
    
    private func handleScore(topScore: inout Int) {
        currentScore += 1
        if currentScore > topScore {
            topScore = currentScore
        }
    }
    
    public func leaveGame() {
        isAnswerPicked = false
        isGameStarted = false
        currentScore = 0
        gameLoadingState = .inactive
    }
    
    public func reset(topScore: inout Int) {
        topScore = 0
    }
    
    @MainActor
    public func nextRound() async {
        isAnswerPicked = false
        await getFourPossibleAnswers()
    }
    
    public func checkIfSameName(pokemon: Pokemon) -> Bool {
        pokemon.name == pokemonDetail?.name
    }
    
    public func checkIfSameNameAndAnswerPicked(pokemon: Pokemon) -> Bool {
        checkIfSameName(pokemon: pokemon) && isAnswerPicked
    }
}
