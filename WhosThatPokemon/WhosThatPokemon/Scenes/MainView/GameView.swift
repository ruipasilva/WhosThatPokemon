//
//  GameView.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewViewModel()
    @AppStorage("topScore") private var topScore = 0
    
    let columns = [
        GridItem(.adaptive(minimum: 200, maximum: 400)),
        GridItem(.adaptive(minimum: 200, maximum: 400)),
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
            titleView
            VStack {
                imageView
                multipleChoiceView
                nextButton
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
            
            HStack {
                Text("Top Score: \(topScore)")
                Text("Current Score: \(viewModel.currentScore)")
            }
            .monospacedDigit()
            .font(.subheadline)
            .padding(.top)
            
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
    
    private var imageView: some View {
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
    
    private func imageLoadedView(pokemon: PokemonDetail) -> some View {
        Group {
            Spacer(minLength: 180)
            AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { image in
                image
                
                    .image?.resizable()
                    .aspectRatio(contentMode: .fit)
                    .if(!viewModel.isAnswerPicked, view: { view in
                        view.colorMultiply(.black.opacity(0.5))
                    })
            }
            VStack {
                Text("It's \(pokemon.name.capitalized)!")
                    .font(.largeTitle)
                    .foregroundStyle(Color.yellow)
                    .shadow(color: .blue, radius: 10)
                HStack {
                    Text("You've picked: \(viewModel.selectedAnswer.capitalized)")
                }
            }
            .opacity(viewModel.isAnswerPicked ? 1 : 0)
            
        }
    }
    
    private var multipleChoiceView: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
            ForEach(viewModel.fourPossibleAnswers, id: \.name) { pokemon in
                Button("\(pokemon.name.capitalized)") {
                        viewModel.isAnswerPicked = true
                        viewModel.isAnswerCorrect = true
                        viewModel.selectedAnswer = pokemon.name
                    if pokemon.name == viewModel.pokemonDetail?.name {
                        viewModel.currentScore += 1
                        if viewModel.currentScore > topScore {
                            topScore = viewModel.currentScore
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(!viewModel.isAnswerPicked ? .yellow : pokemon.name == viewModel.pokemonDetail?.name ? .green : .red)
                .shadow(color: .blue, radius: 2)
                .opacity(0.8)
                
            }
        }
        .padding()
    }
    
    private var nextButton: some View {
        Group {
            if viewModel.isGameStarted {
                Button("Next Pokemon") {
                    Task {
                        viewModel.isAnswerCorrect = false
                        viewModel.isAnswerPicked = false
                        await viewModel.getFourPossibleAnswers()
                    }
                }
                .primaryButtonStyling()
                .padding(.bottom, 12)
            }
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

#Preview {
    GameView()
}
