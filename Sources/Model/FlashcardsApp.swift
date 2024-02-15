//
//  FlashcardsApp.swift
//  Flashcards
//

import Foundation

enum FlashcardsApp: String, CaseIterable, Identifiable {

    case quizlet
    case ankiCards

    var id: String { rawValue }

    var name: String {
        switch self {
        case .quizlet:
            "Quizlet"
        case .ankiCards:
            "Anki (Cards)"
        }
    }

    var description: String {
        switch self {
        case .ankiCards:
            "Ignore fields that are not on the front or back"
        default:
            ""
        }
    }

}
