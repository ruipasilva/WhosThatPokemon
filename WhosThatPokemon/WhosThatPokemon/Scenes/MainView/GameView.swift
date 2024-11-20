//
//  GameView.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewViewModel()
    
    let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 400)),
        GridItem(.adaptive(minimum: 200, maximum: 400)),
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
            titleView
            VStack {
                switch viewModel.gameLoadingState {
                case .loading:
                    ProgressView()
                        .frame(maxHeight: .infinity)
                case .inactive:
                    inactiveView
                case .imageLoaded(pokemon: let pokemon):
                    imageLoadedView(pokemon: pokemon)
                case .failed(error: let error):
                    Text("Error: \(error)")
                }
                Spacer()
            }
            
            
        }
        .ignoresSafeArea()
    }
    
    private var titleView: some View {
        VStack {
            Spacer()
                .frame(height: 120)
            Text("Who's that pokemon?")
                .font(.largeTitle)
                .rotationEffect(.degrees(-10))
                .foregroundStyle(Color.yellow)
                .shadow(color: .blue, radius: 10)
            
            Spacer()
        }
    }
    
    private var inactiveView: some View {
        Button("Start Game") {
            Task {
                await viewModel.getFourPossibleAnswers()
            }
            print(viewModel.fourPossibleAnswers)
        }
        .primaryButtonStyling()
        .frame(maxHeight: .infinity, alignment: .center)
    }
    
    private func imageLoadedView(pokemon: PokemonDetail) -> some View {
        Group {
            Spacer(minLength: 180)
            AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { image in
                image
                
                    .image?.resizable()
                    .aspectRatio(contentMode: .fit)
                    .if(!viewModel.isAnsweredRevealed, view: { view in
                        view.colorMultiply(.black.opacity(0.5))
                    })
            }
            withAnimation {
                Text("It's \(pokemon.name.capitalized)!")
                    .font(.largeTitle)
                    .foregroundStyle(Color.yellow)
                    .shadow(color: .blue, radius: 10)
                    .opacity(viewModel.isAnsweredRevealed ? 1 : 0)
            }
            
            LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                ForEach(viewModel.fourPossibleAnswers, id: \.name) { pokemon in
                    Button("\(pokemon.name.capitalized)") {
                        
                        if pokemon.name == viewModel.pokemonDetail?.name {
                            viewModel.isAnsweredRevealed = true
                            viewModel.isAnswerPicked = true
                            viewModel.isAnswerCorrect = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(!viewModel.isAnswerPicked ? .yellow : pokemon.name == viewModel.pokemonDetail?.name ? .green : .red)
                    .shadow(color: .blue, radius: 2)
                    .opacity(0.8)
                    
                }
            }
            .padding()
            
            Button("Next Pokemon") {
                Task {
                    viewModel.isAnswerCorrect = false
                    viewModel.isAnsweredRevealed = false
                    viewModel.isAnswerPicked = false
                    await viewModel.getFourPossibleAnswers()
                }
            }
            .primaryButtonStyling()
        }
    }
}

struct PrimaryButtonStyling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .tint(.yellow)
            .shadow(color: .blue, radius: 2)
            .opacity(0.8)
    }
}

struct MultipleChoiceButtonStyling: ViewModifier {
    var isCorrectAnswer: Bool
    var isAnswerPicked: Bool
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .tint(!isAnswerPicked ? .yellow : (isCorrectAnswer ? .green : .red))
            .shadow(color: .blue, radius: 2)
            .opacity(0.8)
    }
}

#Preview {
    GameView()
}
