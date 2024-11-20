//
//  Extensions.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 20/11/2024.
//

import SwiftUI

extension View {
    @ViewBuilder public func `if`<T: View>(_ condition: Bool, view: (Self) -> T) -> some View {
        if condition {
            view(self)
        } else {
            self
        }
    }
    
    func primaryButtonStyling() -> some View {
        modifier(PrimaryButtonStyling())
    }
    
    func multipleChoiceButtonStyling(isAnswerCorrect: Bool, isAnswerPicked: Bool) -> some View {
        modifier(MultipleChoiceButtonStyling(isCorrectAnswer: isAnswerCorrect, isAnswerPicked: isAnswerPicked))
    }
}
