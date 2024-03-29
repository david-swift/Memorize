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
    private let columnName = Expression<String>("name")

    // Sets Table types
    private let tableSets = Table("sets")
    /* id: columnID */
    /* name: columnName */
    private let setsSide = Expression<String>("answer_side")

    // Flashcards Table types
    private let tableFlashcards = Table("flashcards")
    /* id: columnID */
    private let flashcardsSet = Expression<Int64>("sets_id") // Foreign Key: sets[id]
    private let flashcardsDifficulty = Expression<Int?>("difficulty")
    private let flashcardsFront = Expression<String?>("front")
    private let flashcardsBack = Expression<String?>("back")

    // Keywords Table types
    private let tableKeywords = Table("keywords")
    /* id: columnID */
    /* name: columnName */

    // Sets to Keywords Table types
    private let tableSetsKeywords = Table("sets_keywords")
    /* id: columnID */
    private let setsKeywordsSet = Expression<Int64>("sets_id")
    private let setsKeywordsKeyword = Expression<Int64>("keywords_id")

    private var connection: Connection?

    private let fileManager = FileManager.default

    init() {
        sets = []

        do {
            connection = try Connection(databasePath().path)

            print("Check data directory, create if not exist")
            checkDataDir()
            print("Create non-exisitent tables in database")
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
            // Sets Table
            try database.run(tableSets.create(ifNotExists: true) { table in
                table.column(columnID, primaryKey: .autoincrement)
                table.column(columnName)
                table.column(setsSide)
                table.check(setsSide == "front" || setsSide == "back")
            })

            // Flashcards Table
            try database.run(tableFlashcards.create(ifNotExists: true) { table in
                table.column(columnID, primaryKey: .autoincrement)
                table.column(flashcardsSet, references: tableSets, columnID)
                table.column(flashcardsDifficulty, defaultValue: 0)
                table.column(flashcardsFront)
                table.column(flashcardsBack)
            })

            // Keywords Table
            try database.run(tableKeywords.create(ifNotExists: true) { table in
                table.column(columnID, primaryKey: .autoincrement)
                table.column(columnName)
            })

            // Sets to Keywords Table
            try database.run(tableSetsKeywords.create(ifNotExists: true) { table in
                table.column(columnID, primaryKey: .autoincrement)
                table.column(setsKeywordsSet, references: tableSets, columnID)
                table.column(setsKeywordsKeyword, references: tableKeywords, columnID)
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
                print("Migrate set " + item.name)

                try database.run(tableSets.insert(
                    columnName <- item.name,
                    setsSide <- item.answerSide.rawValue
                ))

                for keyword in item.keywords.nonOptional {
                    try database.run(tableSetsKeywords.insert(
                        setsKeywordsSet <- Int64(index + 1),
                        setsKeywordsKeyword <- addKeyword(keyword)
                    ))
                }

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
                sets.append(FlashcardsSet(name: item[columnName], flashcards: loadFlashcards(id: item[columnID])))
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

    /// Insert keyword, if non-existent
    /// - Returns: The id of the keyword
    func addKeyword(_ keyword: String) -> Int64 {
        var id = keywordID(keyword)

        guard let database = connection else {
            return id
        }
        do {
            if id == 0 {
                try database.run(tableKeywords.insert(columnName <- keyword))
                id = keywordID(keyword)
            }
        } catch {
            print(error)
        }

        return id
    }

    /// Find keyword in keywords table
    /// - Returns: The id of the keyword
    func keywordID(_ keyword: String) -> Int64 {
        var id: Int64 = 0

        guard let database = connection else {
            return id
        }
        do {
            for item in try database.prepare(tableKeywords.filter(columnName == keyword)) {
                id = item[columnID]
            }
        } catch {
            print(error)
        }

        return id
    }

}
