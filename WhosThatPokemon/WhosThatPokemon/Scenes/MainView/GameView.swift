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
            Color.mainViewBackground
            titleView
            imageView
            bottomButtons
        }
        .ignoresSafeArea()
    }
    
    private var titleView: some View {
        VStack {
            Spacer()
                .frame(height: 120)
            Text("Who's that pokemon?")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(Color.black.opacity(0.8))
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
            .font(.subheadline)
            .fontWeight(.semibold)
            .monospacedDigit()
            .padding(.top)
            .opacity(viewModel.isGameStarted ? 1 : 0)
            Spacer()
        }
    }
    
    private var imageView: some View {
        Group {
            switch viewModel.gameLoadingState {
            case .loading:
                ProgressView()
                    .frame(maxHeight: .infinity)
            case .inactive:
                inactiveView
            case .imageLoaded(pokemon: let pokemon):
                imageLoadedView(pokemon: pokemon)
            case .failed(error: let error):
                Text("Something went wrong with error: \(error)")
            }
        }
    }
    
    private var bottomButtons: some View {
        VStack {
            if viewModel.isGameStarted {
                Spacer()
                multipleChoiceView
                moreOptionsView
            }
        }
    }
    
    private var inactiveView: some View {
        VStack(spacing: 10) {
            Button("Start Game!") {
                Task {
                    await viewModel.getFourPossibleAnswers()
                }
            }
            .inactiveViewModifier()
            
            Button("Reset Top Score!") {
                Task {
                    viewModel.reset(score: &topScore)
                }
            }
            .inactiveViewModifier()
        }
    }

    
    private func imageLoadedView(pokemon: PokemonDetail) -> some View {
        VStack {
            Spacer()
            AsyncImage(url: URL(string: pokemon.sprites.frontDefault)) { image in
                image
                    .image?.resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                    
                    .conditionalModifier(!viewModel.isAnswerPicked, view: { view in
                        view.colorMultiply(.black.opacity(0.5))
                    })
                    .changeEffect(.spin, value: viewModel.isAnswerPicked)
            }
            
            Group {
                Text("It's \(pokemon.name.capitalized)!")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color.white)
                HStack {
                    Text("You guessed \(viewModel.selectedAnswer.capitalized)")
                        .foregroundStyle(Color.brown.opacity(0.8))
                        .fontWeight(.bold)
                }
            }
            .opacity(viewModel.isAnswerPicked ? 1 : 0)
            Spacer()
        }
    }
    
    private var multipleChoiceView: some View {
        LazyVGrid(columns: gridItemLayout, spacing: 10) {
            ForEach(viewModel.firstFourRandomPokemons, id: \.name) { pokemon in
                Button("\(pokemon.name.capitalized)") {
                    viewModel.selectAnswer(pokemon, topScore: &topScore)
                }
                .multipleChoiceModifier()
                .conditionalModifier(!viewModel.isAnswerPicked, view: { view in
                    view
                        .background(.regularMaterial.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
                        .environment(\.colorScheme, .dark)
                })
                .conditionalModifier(viewModel.isAnswerPicked, view: { view in
                    view
                        .background(viewModel.checkIfSameName(pokemon: pokemon) ? .green : .red, in: RoundedRectangle(cornerRadius: 8))
                        .opacity(0.8)
                })
                .conditionalEffect(.repeat(.shine, every: .seconds(1)), condition: viewModel.checkIfSameName(pokemon: pokemon) && viewModel.isAnswerPicked)
            }
        }
        .padding()
    }
    
    private var moreOptionsView: some View {
        HStack(spacing: 10) {
            if viewModel.isGameStarted {
                
                Button("Leave Game") {
                    viewModel.leaveGame()
                }
                .bottomButtonsModifier(textColor: .black, backgroundColor: .white, opacity: 1.0)
                
                Button("Next Pokemon") {
                    Task {
                        await viewModel.nextRound()
                    }
                }
                .bottomButtonsModifier(textColor: .white, backgroundColor: .black, opacity: 0.6)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 28)
    }
}

#Preview {
    GameView()
}
