//
//  ImportNavigationDestination.swift
//  Memorize
//

import Adwaita

enum ImportNavigationDestination: CustomStringConvertible {

    case tutorial(app: FlashcardsApp)
    case paste(app: FlashcardsApp)

    var description: String {
        switch self {
        case let .tutorial(app):
            app.name
        case let .paste(app):
            app.name
        }
    }

}
