//
//  WhosThatPokemonApp.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import SwiftUI

@main
struct WhosThatPokemonApp: App {
    @StateObject private var viewModel = GameViewViewModel()
    var body: some Scene {
        WindowGroup {
            GameView(viewModel: viewModel)
        }
    }
}
