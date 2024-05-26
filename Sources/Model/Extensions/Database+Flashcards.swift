//
//  Database+Flashcards.swift
//  Memorize
//

import SQLite

extension Database {

    /// Load all flashcards for set
    /// - Returns: The Flashcards.
    func loadFlashcards(toSet: inout FlashcardsSet) -> [Flashcard] {
        if toSet.flashcardsExpired == true {
            toSet.flashcards = []

            guard let database = connection else {
                return []
            }
            do {
                for item in try database.prepare(tableFlashcards.filter(flashcardsSet == toSet.id)) {
                    toSet.flashcards.append(Flashcard(
                        id: item[columnID],
                        front: item[flashcardsFront],
                        back: item[flashcardsBack],
                        difficulty: item[flashcardsDifficulty]
                    ))
                }
            } catch {
                print("Error loading flashcards for set \(toSet.name) (\(toSet.id)): \(error)")
            }

            toSet.flashcardsExpired = false
        }

        return toSet.flashcards
    }

    /// Add a flashcard
    /// - Returns the flashcard's id
    func addFlashcard(toSet: inout FlashcardsSet, front: String, back: String) {
        guard let database = connection else {
            return
        }
        do {
            try database.run(tableFlashcards.insert(
                flashcardsSet <- toSet.id,
                flashcardsFront <- front,
                flashcardsBack <- back
            ))
            toSet.flashcardsExpired = true
        } catch {
            print("Error inserting flashcard: \(error)")
        }
    }

    /// Update a flashcard
    func updateFlashcard(id: Int64, newFront: String = "", newBack: String = "", newDifficulty: Int64 = -1) {
        var columns = [Setter]()

        if !newFront.isEmpty {
            columns.append(flashcardsFront <- newFront)
        }
        if !newBack.isEmpty {
            columns.append(flashcardsBack <- newBack)
        }
        if newDifficulty >= 0 {
            columns.append(flashcardsDifficulty <- newDifficulty)
        }

        guard let database = connection else {
            return
        }
        do {
            try database.run(tableFlashcards.filter(columnID == id).update(columns))
            // TODO #37: Find set and set.flashcardsExpired = true
        } catch {
            print("Error updating flashcard \(id): \(error)")
        }
    }

    /// Delete a flashcard
    func deleteFlashcard(id: Int64, fromSet: Int64) {
        guard let database = connection else {
            return
        }
        do {
            // TODO #37: Find set and set.flashcardsExpired = true
            try database.run(tableFlashcards.filter(columnID == id).delete())
        } catch {
            print("Error deleting flashcard \(id): \(error)")
        }
    }

}
