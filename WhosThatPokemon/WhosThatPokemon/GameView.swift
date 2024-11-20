//
//  GameView.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.gameLoadingState {
            case .loading:
                ProgressView()
            case .inactive:
                Button("Start Game") {
                    Task {
                        await viewModel.getPokemon(with: viewModel.generateRandomPokemonId())
                    }
                }
            case .imageReveiled(pokemon: let pokemon):
                AsyncImage(url: URL(string: pokemon.sprites.frontDefault))
            case .failed(error: let error):
                Text("Error: \(error)")
            }
            
            Button("Next Pokemon") {
                Task {
                   await viewModel.getPokemon(with: viewModel.generateRandomPokemonId())
                }
            }
        }
        .padding()
    }
}
