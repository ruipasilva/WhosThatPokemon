//
//  GameView.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import SwiftUI
import Pow

struct GameView: View {
    @ObservedObject private var viewModel: GameViewViewModel
    @AppStorage("topScore") private var topScore = 0
    
    private var gridItemLayout = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
    
    public init(viewModel: GameViewViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            titleView
            imageView
            bottomButtons
        }
        .ignoresSafeArea()
    }
    
    private var backgroundGradient: some View {
        LinearGradient(colors: [.mainViewBackground, .bottomViewBackgeound], startPoint: .top, endPoint: .bottom)
    }
    
    private var titleView: some View {
        VStack {
            Spacer()
                .frame(height: 120)
            Text("Who's that pokemon?")
                .titleViewModifier()
            HStack(alignment: .center) {
                scroresView(score: topScore)
                Text("|")
                scroresView(score: viewModel.currentScore)
            }
            .scoreViewModifier(viewModel.isGameStarted)
            Spacer()
        }
    }
    
    private func scroresView(score: Int) -> some View {
        HStack(spacing: 4) {
            Text("Top Score:")
            Text("\(score)")
                .changeEffect(.rise(origin: UnitPoint(x: 0.75, y: 1.5)) {
                    Text("+1")
                        .foregroundStyle(.green)
                }, value: score)
        }
    }
    
    private var imageView: some View {
        Group {
            switch viewModel.gameLoadingState {
            case .loading:
                ProgressView()
            case .inactive:
                inactiveView
            case .imageLoaded(pokemon: let pokemon):
                imageLoadedView(pokemonDetail: pokemon)
            case .failed(error: let error):
                Text("Something went wrong with error: \(error)")
                    .padding(.horizontal)
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
                    viewModel.reset(topScore: &topScore)
                }
            }
            .disabled(topScore == 0)
            .inactiveViewModifier()
        }
    }
    
    private func imageLoadedView(pokemonDetail: PokemonDetail) -> some View {
        VStack {
            Spacer()
            AsyncImage(url: URL(string: pokemonDetail.sprites.frontDefault)) { image in
                image
                    .image?.resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                    .conditionalModifier(!viewModel.isAnswerPicked, view: { view in
                        view.colorMultiply(.black.opacity(0.5))
                    })
                    .changeEffect(.spin, value: viewModel.isAnswerPicked)
            }
            Group {
                Text("It's \(pokemonDetail.name.capitalized)!")
                    .pokemonNameRevealedModifier()
                HStack {
                    Text(pokemonDetail.name == viewModel.selectedAnswer
                         ? "You guessed it right"
                         : "Oh no! Better luck next time!")
                    .rightOrWrongModifier()
                }
            }
            .opacity(viewModel.isAnswerPicked ? 1 : 0)
            Spacer()
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
                .conditionalEffect(.repeat(.shine, every: .seconds(1)), condition: viewModel.checkIfSameNameAndAnswerPicked(pokemon: pokemon))
            }
        }
        .padding()
    }
    
    private var moreOptionsView: some View {
        HStack(spacing: 10) {
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
        .bottomButtonStakModifier()    }
}

#Preview {
    GameView(viewModel: .init())
}
