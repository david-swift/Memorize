//
//  EditNavigationDestination.swift
//  Memorize
//

import Adwaita

enum EditNavigationDestination: CustomStringConvertible {

    case tag(tag: String)

    var description: String {
        switch self {
        case let .tag(tag):
            Loc.specificTag(tag: tag)
        }
    }

}
