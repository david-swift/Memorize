//
//  Database+Flashcards.swift
//  Memorize
//

import SQLite

extension Database {

    /// Load all flashcards for set
    /// - Returns: The Flashcards.
    func loadFlashcards(toSet: inout FlashcardsSet) {
        toSet.flashcards = []

        guard let database = connection else {
            return
        }
        do {
            for item in try database.prepare(tableFlashcards.filter(flashcardsSet == toSet.id)) {
                toSet.flashcards.append(item[columnID])
            }
        } catch {
            print("Error loading flashcards for set \(toSet.name) (\(toSet.id)): \(error)")
        }
    }

    /// Add a flashcard
    /// - Returns the flashcard's id
    func addFlashcard(toSet: inout FlashcardsSet, front: String, back: String) {
        var id: Int64 = 0

        guard let database = connection else {
            return
        }
        do {
            id = try database.run(tableFlashcards.insert(
                flashcardsSet <- toSet.id,
                flashcardsFront <- front,
                flashcardsBack <- back
            ))
            toSet.flashcards.append(id)
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
        } catch {
            print("Error updating flashcard \(id): \(error)")
        }
    }

    /// Delete a flashcard
    func deleteFlashcard(id: Int64, inSet: inout FlashcardsSet) {
        guard let database = connection else {
            return
        }
        do {
            try database.run(tableFlashcards.filter(columnID == id).delete())
            inSet.flashcards = inSet.flashcards.filter { $0 != id }
        } catch {
            print("Error deleting flashcard \(id): \(error)")
        }
    }

    /// Load flashcard data by id
    /// TODO #37: Replace this function with for-loops over SELECT statement in Views (Swift Views, not SQL Views)
    /// - Returns: The flashcard.
    func resolveFlashcard(id: Int64) -> Flashcard {
        var flashcard: Flashcard

        guard let database = connection else {
            return flashcard
        }
        do {
            for item in try database.prepare(tableFlashcards.filter(columnID == id)) {
                flashcard = Flashcard(
                    id: item[columnID],
                    front: item[flashcardsFront],
                    back: item[flashcardsBack],
                    difficulty: item[flashcardsDifficulty]
                )
            }
        } catch {
            print("Error resolving flashcard \(id): \(error)")
        }

        return flashcard
    }

}
