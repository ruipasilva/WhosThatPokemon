//
//  WhosThatPokemonTests.swift
//  WhosThatPokemonTests
//
//  Created by Rui Silva on 21/11/2024.
//

import XCTest
@testable import WhosThatPokemon

final class WhosThatPokemonTests: XCTestCase {
    typealias Mocks = MockPokemons
    
    var sut: GameViewViewModel!
    var mockNetworkManager: NetworkManagerMock!
    
    override func setUp() {
        super.setUp()
        
        sut = GameViewViewModel()
        mockNetworkManager = NetworkManagerMock()
        sut.networkManager = mockNetworkManager
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        mockNetworkManager = nil
    }
    
    func test_FetchSinglePokemon_WhenSuccessful() async {
        //Given
        let expectedSprites = Sprites(frontDefault: "test.png")
        let expectedPokemonDetail = PokemonDetail(name: "Pikachu", sprites: expectedSprites)
        
        mockNetworkManager.pokemonDetail = expectedPokemonDetail
        
        sut.allPokemons = Mocks.allPokemons
        
        //When
        await sut.getFourPossibleAnswers()
        
        //Then
        XCTAssertEqual(sut.pokemonDetail?.name, mockNetworkManager.pokemonDetail?.name)
        XCTAssertTrue(sut.isGameStarted)
        XCTAssertEqual(sut.allPokemons.count, 4)
    }
    
    func test_FetchSinglePokemon_WhenFailed() async {
        //Given
        mockNetworkManager.shouldReturnError = true
        sut.allPokemons = Mocks.allPokemons
        
        //When
        await sut.getFourPossibleAnswers()
        
        // Then
        XCTAssertNil(mockNetworkManager.pokemonDetail)
        XCTAssertEqual(sut.isGameStarted, false)
    }
    
    func test_FetchAllPokemons_WhenSuccessful() async {
        //Given
        mockNetworkManager.shouldReturnError = true
        let expectedAllPokemons: [Pokemon] = Mocks.allPokemons
        
        mockNetworkManager.pokemonList?.results = expectedAllPokemons
        
        //When
        await sut.getAllPokemons()
        
        //Then
        XCTAssertEqual(sut.allPokemons.first?.name, mockNetworkManager.pokemonList?.results.first?.name)
        XCTAssertEqual(sut.isGameStarted, false)
    }
    
    func test_FetchAllPokemons_WhenFailed() async {
        //Given
        let expectedAllPokemons: [Pokemon] = Mocks.allPokemons
        
        mockNetworkManager.pokemonList?.results = expectedAllPokemons
        
        //When
        await sut.getAllPokemons()
        
        //Then
        XCTAssertNil(mockNetworkManager.pokemonList)
        XCTAssertEqual(sut.isGameStarted, false)
    }
    
    func test_WhenRightAnswerSelected_ThenScoreIncremented() {
        //Given
        let initialScore = 0
        let expectedScore = 1
        var topScore = Int.max
        let correctPokemon = Mocks.singlePokemon
        
        sut.currentScore = initialScore
        sut.pokemonDetail = Mocks.singlePokemonDetail
        
        //When
        sut.selectAnswer(correctPokemon, topScore: &topScore)
        
        //Then
        XCTAssertEqual(sut.selectedAnswer, correctPokemon.name)
        XCTAssertEqual(sut.currentScore, expectedScore)
    }
    
    func test_WhenWrongAnswerSelected_ThenScoreNotIncremented() {
        //Given
        let initialScore = 0
        let expectedScore = 0
        var topScore = Int.max
        let wrongPokemon = Mocks.singlePokemon
        
        sut.currentScore = initialScore
        
        // When
        sut.selectAnswer(wrongPokemon, topScore: &topScore)
        
        // Then
        XCTAssertEqual(sut.currentScore, expectedScore)
    }
    
    func test_WhenCurrentScoreIsHigherThanTopScore_ThenTopScoreIsUpdated() {
        //Given
        let currentScore = 4
        var topScore = 3
        let correctPokemon = Mocks.singlePokemon
        
        sut.currentScore = currentScore
        sut.pokemonDetail = Mocks.singlePokemonDetail
        
        //When
        sut.selectAnswer(correctPokemon, topScore: &topScore)
        
        // Then
        XCTAssertEqual(sut.currentScore, topScore)
    }
    
    func test_WhenCurrentScoreIsLowerThanTopScore_ThenTopScoreIsNotUpdated() {
        //Given
        let currentScore = 1
        var topScore = 3
        let correctPokemon = Mocks.singlePokemon
        
        sut.currentScore = currentScore
        sut.pokemonDetail = Mocks.singlePokemonDetail
        
        //When
        sut.selectAnswer(correctPokemon, topScore: &topScore)
        
        // Then
        XCTAssertLessThan(currentScore, topScore)
    }
    
    func test_WhenUserLeavesGame_ThenCurrentScoreIsReset() {
        //Given
        let currentScore = 4
        
        sut.currentScore = currentScore
        
        //When
        sut.leaveGame()
        
        //Then
        XCTAssertEqual(sut.currentScore, 0)
    }
    
    func test_WhenUserResetsScore_ThenScoreIsReset() {
        //Given
        var topScore = 10
        let resetScore = 0
        
        // When
        sut.reset(topScore: &topScore)
        
        //Then
        XCTAssertEqual(topScore, resetScore)
    }
}
