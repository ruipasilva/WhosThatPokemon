//
//  NetworkHelpers.swift
//  WhosThatPokemon
//
//  Created by Rui Silva on 19/11/2024.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidData
    case invalidResponse
    case unableToComplete

    public var title: String {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .invalidData:
            "Invalid Data"
        case .invalidResponse:
            "Invalid Response"
        case .unableToComplete:
            "Unable to complete"
        }
    }
}

public enum GameLoadingState {
    case inactive
    case loading
    case imageReveiled(pokemon: Pokemon)
    case failed(error: String)
}
