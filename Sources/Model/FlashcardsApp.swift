//
//  FlashcardsApp.swift
//  Memorize
//

import Foundation

enum FlashcardsApp: String, CaseIterable, Identifiable {

    case quizlet
    case anki
    case csv

    var id: String { rawValue }

    var name: String {
        switch self {
        case .quizlet:
            Loc.quizlet
        case .anki:
            Loc.anki
        case .csv:
            Loc.csv
        }
    }

}
