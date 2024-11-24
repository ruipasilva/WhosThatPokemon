//
//  Extensions.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 20/11/2024.
//

import SwiftUI

extension View {
    @ViewBuilder public func conditionalModifier<T: View>(_ condition: Bool, view: (Self) -> T) -> some View {
        if condition {
            view(self)
        } else {
            self
        }
    }
    
    func inactiveViewModifier() -> some View {
        modifier(InactiveViewButtonModifier())
    }
    
    func multipleChoiceModifier() -> some View {
        modifier(MultipleChoiceModifier())
    }
    
    func bottomButtonsModifier(textColor: Color,
                               backgroundColor: Color,
                               opacity: Double) -> some View {
        modifier(BottomButtonsModifer(textColor: textColor,
                                      backgroundColor: backgroundColor,
                                      opacity: opacity))
    }
    
    func scoreViewModifier(_ isGameStarted: Bool) -> some View {
        modifier(ScoreViewModifier(isGameStarted: isGameStarted))
    }
    
    func pokemonNameRevealedModifier() -> some View {
        modifier(PokemonNameRevealedModifier())
    }
    
    func rightOrWrongModifier() -> some View {
        modifier(RightOrWrongModifier())
    }
    
    func bottomButtonStakModifier() -> some View {
        modifier(BottomButtonsStackModifier())
    }
}
