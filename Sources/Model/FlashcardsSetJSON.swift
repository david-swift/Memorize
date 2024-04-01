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
    var tags: [String]? {
        didSet {
            filterTags()
        }
    }
    var studyTags: [String]?
    var testTags: [String]?
    // swiftlint:enable discouraged_optional_collection
    var flashcards: [FlashcardJSON]
    var test: [String] = []
    var answerSide: Flashcard.Side = .back
    // swiftlint:disable discouraged_optional_boolean
    var studyAllFlashcards: Bool?
    var testAllFlashcards: Bool?
    // swiftlint:enable discouraged_optional_boolean
    var numberOfQuestions: Int?

    var answerWithBack: Bool {
        get {
            answerSide == .back
        }
        set {
            answerSide = newValue ? .back : .front
        }
    }

    var studyFlashcards: [FlashcardJSON] {
        if answerSide == .back {
            return flashcards(tags: studyAllFlashcards.nonOptional ? nil : studyTags.nonOptional)
        } else {
            return flashcards(tags: studyAllFlashcards.nonOptional ? nil : studyTags.nonOptional).map { flashcard in
                var newCard = flashcard
                newCard.front = flashcard.back
                newCard.back = flashcard.front
                return newCard
            }
        }
    }

    var testFlashcards: [FlashcardJSON] {
        get {
            if answerSide == .back {
                return flashcards(tags: testAllFlashcards.nonOptional ? nil : testTags.nonOptional)
            } else {
                return flashcards(tags: testAllFlashcards.nonOptional ? nil : testTags.nonOptional).map { flashcard in
                    var newCard = flashcard
                    newCard.front = flashcard.back
                    newCard.back = flashcard.front
                    return newCard
                }
            }
        }
        set {
            for flashcard in newValue {
                flashcards[safe: flashcards.firstIndex { $0.id == flashcard.id }]?.gameData = flashcard.gameData
            }
        }
    }

    var score: Int? {
        let testFlashcards = testFlashcards.filter { test.contains($0.id) }
        guard testFlashcards.first?.gameData.lastInput != nil else {
            return nil
        }
        var score = 0
        for flashcard in testFlashcards where flashcard.back == flashcard.gameData.lastInput {
            score += 1
        }
        return score
    }

    var filteredStudyCards: [String] {
        studyFlashcards.filter { $0.gameData.difficulty != 0 }.map { $0.id }
    }

    var completedCardsCount: Int {
        studyFlashcards.count - filteredStudyCards.count
    }

    init(name: String = Loc.newSet, flashcards: [Flashcard] = [
        .init(front: Loc.question(index: 1), back: Loc.answer),
        .init(front: Loc.question(index: 2), back: Loc.answer)
    ]) {
        id = UUID().uuidString
        self.name = name
        self.flashcards = flashcards
    }

    mutating func check() {
        for index in flashcards.indices {
            flashcards[safe: index]?.check()
        }
    }

    mutating func done() {
        test = []
        for index in flashcards.indices {
            flashcards[safe: index]?.done()
        }
    }

    mutating func resetStudyProgress() {
        setDifficulty(0)
    }

    mutating func setDifficulty(_ difficulty: Int) {
        for index in flashcards.indices {
            flashcards[safe: index]?.gameData.difficulty = difficulty
        }
    }

    func score(_ query: String?) -> Int {
        var totalScore = 1
        if let query, !query.isEmpty {
            totalScore = name.search(query) ? 5 : 0
            for keyword in keywords.nonOptional {
                totalScore += keyword.search(query) ? 1 : 0
            }
        }
        return totalScore
    }

    mutating func filterTags() {
        for (index, flashcard) in flashcards.enumerated() {
            flashcards[safe: index]?.tags.nonOptional = flashcard.tags.nonOptional
                .filter { tags.nonOptional.contains($0) }
        }
        studyTags.nonOptional = studyTags.nonOptional.filter { tags.nonOptional.contains($0) }
        testTags.nonOptional = testTags.nonOptional.filter { tags.nonOptional.contains($0) }
    }

    // swiftlint:disable discouraged_optional_collection
    func flashcards(tags: [String]?) -> [FlashcardJSON] {
        if let tags {
            return flashcards.filter { $0.tags.nonOptional.contains { tags.contains($0) } }
        }
        return flashcards
    }
    // swiftlint:enable discouraged_optional_collection

}
