//
//  Search.swift
//  Memorize
//

enum Search {

    case visible(query: String)
    case hidden(query: String)

    var query: String {
        get {
            switch self {
            case let .visible(query), let .hidden(query):
                query
            }
        }
        set {
            switch self {
            case .visible:
                self = .visible(query: newValue)
            case .hidden:
                self = .hidden(query: newValue)
            }
        }
    }

    var effectiveQuery: String {
        visible ? query : ""
    }

    var visible: Bool {
        switch self {
        case .visible:
            true
        case .hidden:
            false
        }
    }

    mutating func show() {
        self = .visible(query: query)
    }

    mutating func toggle() {
        if visible {
            self = .hidden(query: query)
        } else {
            self = .visible(query: query)
        }
    }

}
