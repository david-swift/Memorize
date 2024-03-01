//
//  FlashcardsApp.swift
//  Flashcards
//

import Foundation

enum FlashcardsApp: String, CaseIterable, Identifiable {

    case quizlet
    case anki

    var id: String { rawValue }

    var name: String {
        switch self {
        case .quizlet:
            Loc.quizlet
        case .anki:
            Loc.anki
        }
    }

}
