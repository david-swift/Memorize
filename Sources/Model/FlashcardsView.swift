//
//  FlashcardsView.swift
//  Flashcards
//

import Adwaita

enum FlashcardsView: String, ViewSwitcherOption, Codable {

    case overview
    case study
    case test

    var title: String {
        rawValue.capitalized
    }

    var icon: Icon {
        switch self {
        case .overview:
            return .default(icon: .viewReveal)
        case .study:
            return .default(icon: .mediaPlaybackStart)
        case .test:
            return .default(icon: .findLocation)
        }
    }

    init?(title: String) {
        self.init(rawValue: title.lowercased())
    }

}
