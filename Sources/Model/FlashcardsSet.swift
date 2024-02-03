//
//  FlashcardsSet.swift
//  Flashcards
//

import Foundation

struct FlashcardsSet: Identifiable, Codable {

    let id: String
    var name: String
    // swiftlint:disable discouraged_optional_collection
    var keywords: [String]?
    // swiftlint:enable discouraged_optional_collection
    var flashcards: [Flashcard]
    var test: [String] = []
    var answerSide: Flashcard.Side = .back

    var nonOptionalKeywords: [String] {
        get {
            keywords ?? []
        }
        set {
            keywords = newValue
        }
    }

    var answerWithBack: Bool {
        get {
            answerSide == .back
        }
        set {
            answerSide = newValue ? .back : .front
        }
    }

    var studyFlashcards: [Flashcard] {
        get {
            if answerSide == .back {
                return flashcards
            } else {
                return flashcards.map { flashcard in
                    var newCard = flashcard
                    newCard.front = flashcard.back
                    newCard.back = flashcard.front
                    return newCard
                }
            }
        }
        set {
            if answerSide == .back {
                flashcards = newValue
            } else {
                flashcards = newValue.map { flashcard in
                    var newCard = flashcard
                    newCard.front = flashcard.back
                    newCard.back = flashcard.front
                    return newCard
                }
            }
        }
    }

    var score: Int? {
        let studyFlashcards = studyFlashcards.filter { test.contains($0.id) }
        guard studyFlashcards.first?.gameData.lastInput != nil else {
            return nil
        }
        var score = 0
        for flashcard in studyFlashcards where flashcard.back == flashcard.gameData.lastInput {
            score += 1
        }
        return score
    }

    var filteredStudyCards: [String] {
        flashcards.filter { $0.gameData.difficulty != 0 }.map { $0.id }
    }

    var completedCardsCount: Int {
        flashcards.count - filteredStudyCards.count
    }

    init(name: String = "New Set", flashcards: [Flashcard] = [
        .init(front: "Question 1", back: "Answer"),
        .init(front: "Question 2", back: "Answer")
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

    func score(_ filter: String?) -> Int {
        var totalScore = 1
        if let filter, !filter.isEmpty {
            totalScore = search(filter, in: name) ? 5 : 0
            for keyword in nonOptionalKeywords {
                totalScore += search(filter, in: keyword) ? 1 : 0
            }
        }
        return totalScore
    }

    func search(_ search: String, in text: String) -> Bool {
        guard !search.isEmpty else {
            return true
        }
        var remainder = search.lowercased()[...]
        for char in text.lowercased() where char == remainder[remainder.startIndex] {
            remainder.removeFirst()
            if remainder.isEmpty {
                return true
            }
        }
        return false
    }

}
