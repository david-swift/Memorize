//
//  Database+Flashcards.swift
//  Memorize
//

import SQLite

extension Database {

    /// Add a set to the database
    /// - Returns: The set's id.
    func addSet(name: String) -> Int64 {
        var id: Int64 = 0

        guard let database = connection else {
            return id
        }
        do {
            id = try database.run(tableSets.insert(
                columnName <- name,
                setsSide <- "back"
            ))
            sets.append(FlashcardsSet(
                id: id,
                dbms: self,
                name: name
            ))
            addFlashcard(toSet: &sets[sets.count - 1], front: Loc.question(index: 1), back: Loc.answer)
            addFlashcard(toSet: &sets[sets.count - 1], front: Loc.question(index: 2), back: Loc.answer)
        } catch {
            print("Error inserting set \(name): \(error)")
        }

        return id
    }

    /// Update a set in the database
    func updateSet(id: Int64, newName: String) {
        guard let database = connection else {
            return
        }
        do {
            try database.run(tableSets.filter(columnID == id).update(columnName <- newName))
        } catch {
            print("Error updating set \(id): \(error)")
        }
    }

    /// Delete a set
    func deleteSet(id: Int64) {
        guard let database = connection else {
            return
        }
        do {
            try database.run(tableSets.filter(columnID == id).delete())
        } catch {
            print("Error deleting set \(id): \(error)")
        }
    }

    /// Load all sets
    func loadSets() {
        sets = []

        guard let database = connection else {
            return
        }
        do {
            for item in try database.prepare(tableSets) {
                sets.append(FlashcardsSet(
                    id: item[columnID],
                    dbms: self,
                    name: item[columnName],
                    keywords: loadKeywords(fromSet: item[columnID])
                ))
            }
        } catch {
            print("Error loading sets: \(error)")
        }
    }

    /// Set difficulty for all flashcards in set
    func setDifficulty(_ difficulty: Int64, inSet: inout FlashcardsSet) {
        for flashcard in inSet.flashcards {
            updateFlashcard(id: flashcard.id, newDifficulty: difficulty)
        }
    }

}
