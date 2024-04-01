//
//  FlashcardsSetJSON.swift
//  Memorize
//

import Foundation

struct FlashcardsSetJSON: Identifiable, Codable {

    let id: String
    var name: String
    // swiftlint:disable discouraged_optional_collection
    var keywords: [String]?
    var tags: [String]?
    // swiftlint:enable discouraged_optional_collection
    var flashcards: [FlashcardJSON]
    var test: [String] = []
    var answerSide: Flashcard.Side = .back

    init(name: String = Loc.newSet, flashcards: [FlashcardJSON] = [
        .init(front: Loc.question(index: 1), back: Loc.answer),
        .init(front: Loc.question(index: 2), back: Loc.answer)
    ]) {
        id = UUID().uuidString
        self.name = name
        self.flashcards = flashcards
    }

}
