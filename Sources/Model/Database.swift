//
//  Database.swift
//  Memorize
//

import Adwaita
import Foundation
import SQLite

class Database {

    var sets: [FlashcardsSet] {
        didSet {
            print("Updating sets or flashcards in the database is currently NOT supported")
        }
    }

    private let columnID = Expression<Int64>("id")

    // sets table layout
    private let tableSets = Table("sets")
    private let setsName = Expression<String>("name")
    private let setsSide = Expression<String>("answer_side")

    // flashcards table layout
    private let tableFlashcards = Table("flashcards")
    private let flashcardsSet = Expression<Int64>("sets_id")
    private let flashcardsDifficulty = Expression<Int?>("difficulty")
    private let flashcardsFront = Expression<String?>("front")
    private let flashcardsBack = Expression<String?>("back")

    private var connection: Connection?

    private let fileManager = FileManager.default

    init() {
        sets = []

        do {
            connection = try Connection(databasePath().path)

            print("Check data directory, create if not exist")
            checkDataDir()

            checkDatabase()
            let backupPath = jsonPath().path + ".bak"
            if fileManager.fileExists(atPath: jsonPath().path) &&
               !fileManager.fileExists(atPath: backupPath) {
                print("Migrate JSON to SQLite")
                migrateJSON()

                try fileManager.moveItem(atPath: jsonPath().path, toPath: backupPath)
                print("Conversion finished. Backup of JSON file at " + backupPath)
            }

            loadSets()
        } catch {
            print(error)
        }
    }

    /// Get the settings directory path.
    /// - Returns: The path.
    private func dirPath() -> URL {
        State<Any>
            .userDataDir()
            .appendingPathComponent("io.github.david_swift.Flashcards", isDirectory: true)
    }

    /// Get the JSON user data file path.
    /// - Returns: The path.
    private func jsonPath() -> URL {
        dirPath().appendingPathComponent("sets.json")
    }

    /// Get the database file path.
    /// - Returns: The path.
    private func databasePath() -> URL {
        dirPath().appendingPathComponent("data.sqlite3")
    }

    /// Check whether the data directory exists, and, if not, create it.
    private func checkDataDir() {
        if !fileManager.fileExists(atPath: dirPath().path) {
            try? fileManager.createDirectory(
                at: .init(fileURLWithPath: dirPath().path),
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }

    // Create database tables if they do not exist.
    private func checkDatabase() {
        guard let database = connection else {
            return
        }
        do {
            // sets table rules
            try database.run(tableSets.create(ifNotExists: true) { table in
                table.column(columnID, primaryKey: .autoincrement)
                table.column(setsName)
                table.column(setsSide)
                table.check(setsSide == "front" || setsSide == "back")
            })

            // flashcards table rules
            try database.run(tableFlashcards.create(ifNotExists: true) { table in
                table.column(columnID, primaryKey: .autoincrement)
                table.column(flashcardsSet, references: tableSets, columnID)
                table.column(flashcardsDifficulty, defaultValue: 0)
                table.column(flashcardsFront)
                table.column(flashcardsBack)
            })
        } catch {
            print(error)
        }
    }

    // Migrate the obsolete JSON file to SQLite
    private func migrateJSON() {
        var json: [FlashcardsSet] = []
        let data = try? Data(contentsOf: jsonPath())
        if let data, let value = try? JSONDecoder().decode([FlashcardsSet].self, from: data) {
            json = value
        }

        guard let database = connection else {
            return
        }
        do {
            for (index, item) in json.enumerated() {
                try database.run(tableSets.insert(
                    setsName <- item.name,
                    setsSide <- item.answerSide.rawValue
                ))

                for flashcard in item.flashcards {
                    try database.run(tableFlashcards.insert(
                        flashcardsSet <- Int64(index + 1),
                        flashcardsDifficulty <- flashcard.gameData.difficulty,
                        flashcardsFront <- flashcard.front,
                        flashcardsBack <- flashcard.back
                    ))
                }
            }
        } catch {
            print(error)
        }
    }

    /// Load all sets
    func loadSets() {
        guard let database = connection else {
            return
        }
        do {
            for item in try database.prepare(tableSets) {
                sets.append(FlashcardsSet(name: item[setsName], flashcards: loadFlashcards(id: item[columnID])))
            }
        } catch {
            print(error)
        }
    }

    /// Load all flashcards for set
    /// - Returns: The Flashcards.
    func loadFlashcards(id: Int64) -> [Flashcard] {
        var flashcards: [Flashcard] = []

        guard let database = connection else {
            return flashcards
        }
        do {
            for item in try database.prepare(tableFlashcards.filter(flashcardsSet == id)) {
                flashcards.append(Flashcard(front: item[flashcardsFront] ?? "", back: item[flashcardsBack] ?? ""))
            }
        } catch {
            print(error)
        }

        return flashcards
    }

}
