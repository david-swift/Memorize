//
//  Flashcard.swift
//  Memorize
//

import Foundation

struct Flashcard: SearchScore, Identifiable, Codable {

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
        var lastInput: String?
        var difficulty = 0

    }

    mutating func check() {
        gameData.lastInput = gameData.input
    }

    mutating func done() {
        gameData.input = ""
        gameData.lastInput = nil
    }

    func score(_ query: String?) -> Int {
        var totalScore = 1
        if let query, !query.isEmpty {
            totalScore = 0
            totalScore += front.search(query) ? 5 : 0
            totalScore += back.search(query) ? 5 : 0
            for tag in tags.nonOptional {
                totalScore += tag.search(query) ? 1 : 0
            }
        }
        return totalScore
    }

}
