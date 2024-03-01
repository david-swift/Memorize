//
//  FlashcardsView.swift
//  Memorize
//

import Adwaita

enum FlashcardsView: ViewSwitcherOption, Codable {

    case overview
    case study
    case test

    var title: String {
        switch self {
        case .overview:
            Loc.overview
        case .study:
            Loc.studySwitcher
        case .test:
            Loc.test
        }
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
        switch title {
        case Loc.studySwitcher:
            self = .study
        case Loc.test:
            self = .test
        default:
            self = .overview
        }
    }

}
