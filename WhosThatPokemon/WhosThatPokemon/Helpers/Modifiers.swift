//
//  Modifiers.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 22/11/2024.
//

import SwiftUI

struct InactiveViewButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .padding()
            .buttonStyle(.plain)
            .background(.thinMaterial,in: RoundedRectangle(cornerRadius: 8))
            .environment(\.colorScheme, .dark)
    }
}

struct MultipleChoiceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .buttonStyle(.plain)
    }
}

struct BottomButtonsModifer: ViewModifier {
    var textColor: Color
    var backgroundColor: Color
    var opacity: Double
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(textColor)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .buttonStyle(.plain)
            .background(backgroundColor.opacity(opacity), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct BottomButtonsStackModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.bottom, 28)
    }
}

struct ScoreViewModifier: ViewModifier {
    var isGameStarted: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .fontWeight(.semibold)
            .monospacedDigit()
            .padding(.top)
            .opacity(isGameStarted ? 1 : 0)
    }
}

struct TitleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .fontWeight(.heavy)
    }
}

struct PokemonNameRevealedModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .fontWeight(.heavy)
            .foregroundStyle(Color.white)
    }
}

struct RightOrWrongModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color.brown.opacity(0.8))
            .fontWeight(.bold)
    }
}

