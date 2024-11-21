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
}

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

