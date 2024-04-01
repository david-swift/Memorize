//
//  FlashcardJSON.swift
//  Memorize
//

import Foundation

struct FlashcardJSON: Identifiable, Codable {

    let id: String
    var front = ""
    var back = ""
    var gameData = GameData()
    // swiftlint:disable discouraged_optional_collection
    var tags: [String]?
    // swiftlint:enable discouraged_optional_collection

    init(id: String? = nil, front: String = "", back: String = "") {
        self.id = id ?? UUID().uuidString
        self.front = front
        self.back = back
    }

    enum Side: String, Codable, CaseIterable, Identifiable {

        case front
        case back

        var id: Self { self }

    }

    struct GameData: Codable {

        var input = ""
        var difficulty = 0

    }

}
