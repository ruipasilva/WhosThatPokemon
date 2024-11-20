//
//  GameView.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import SwiftUI
import Pow

struct GameView: View {
    @StateObject private var viewModel = GameViewViewModel()
    @AppStorage("topScore") private var topScore = 0
    
    private var gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.red, .blue], startPoint: .top, endPoint: .bottom)
            titleView
            imageView
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
                HStack {
                    Text("Current Score:")
                    Text("\(viewModel.currentScore)")
                        .changeEffect(.rise(origin: UnitPoint(x: 0.75, y: 0.25)) {
                            Text("+1")
                        }, value: viewModel.currentScore)
                }
                
                
            }
            .monospacedDigit()
            .font(.subheadline)
            .padding(.top)
            .opacity(viewModel.isGameStarted ? 1 : 0)
            
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
                VStack {
                    imageLoadedView(pokemon: pokemon)
                    Spacer()
                    multipleChoiceView
                    moreOptionsView
                }
            case .failed(error: let error):
                Text("Error: \(error)")
            }
            
            
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
                    .changeEffect(.shine, value: viewModel.isAnswerPicked)
                    .changeEffect(.wiggle(rate: .default), value: viewModel.isAnswerPicked)
                
                
            }
            .transition(.movingParts.clock(
                blurRadius: 50
            ))
            .zIndex(1)
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
        LazyVGrid(columns: gridItemLayout, spacing: 10) {
            
            ForEach(viewModel.fourPossibleAnswers, id: \.name) { pokemon in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(!viewModel.isAnswerPicked ? .yellow : pokemon.name == viewModel.pokemonDetail?.name ? .green : .red)
                        .shadow(color: .blue, radius: 2)
                        .opacity(0.8)
                    
                    
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
                    .tint(.clear)
                }
                .conditionalEffect(.repeat(.shine, every: .seconds(1)), condition: (pokemon.name == viewModel.pokemonDetail?.name) && viewModel.isAnswerPicked)
            }
        }
        .padding()
    }
    
    private var moreOptionsView: some View {
        VStack(spacing: 10) {
            if viewModel.isGameStarted {
                Button("Next Pokemon") {
                    Task {
                        viewModel.isAnswerCorrect = false
                        viewModel.isAnswerPicked = false
                        await viewModel.getFourPossibleAnswers()
                    }
                }
                .primaryButtonStyling()
                
                Button("Leave Game") {
                        viewModel.isAnswerCorrect = false
                        viewModel.isAnswerPicked = false
                        viewModel.gameLoadingState = .inactive
                        viewModel.isGameStarted = false
                        viewModel.currentScore = 0
                }
                .primaryButtonStyling()
            }
        }
        .padding(.bottom, 22)
    }
}

#Preview {
    GameView()
}
