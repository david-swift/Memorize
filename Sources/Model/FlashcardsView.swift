//
//  FlashcardsView.swift
//  Memorize
//

import Adwaita

enum FlashcardsView: CustomStringConvertible {

    case study(set: String)
    case test(set: String)

    var description: String {
        switch self {
        case .study:
            Loc.studySwitcher
        case .test:
            Loc.test
        }
    }

}
