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

    let columnID = Expression<Int64>("id")
    let columnName = Expression<String>("name")

    // Sets Table types
    let tableSets = Table("sets")
    /* id: columnID */
    /* name: columnName */
    let setsSide = Expression<String>("answer_side")

    // Flashcards Table types
    let tableFlashcards = Table("flashcards")
    /* id: columnID */
    let flashcardsSet = Expression<Int64>("sets_id") // Foreign Key: sets[id]
    let flashcardsDifficulty = Expression<Int64>("difficulty")
    let flashcardsFront = Expression<String>("front")
    let flashcardsBack = Expression<String>("back")

    // Keywords Table types
    let tableKeywords = Table("keywords")
    /* id: columnID */
    /* name: columnName */

    // Sets to Keywords Table types
    let tableSetsKeywords = Table("sets_keywords")
    /* id: columnID */
    let setsKeywordsSet = Expression<Int64>("sets_id")
    let setsKeywordsKeyword = Expression<Int64>("keywords_id")

    var connection: Connection?

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
            print("Error intializing database: \(error)")
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
            try database.transaction {
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
            }
        } catch {
            print("Error intializing database tables: \(error)")
        }
    }

    // Migrate the obsolete JSON file to SQLite
    private func migrateJSON() {
        var json: [FlashcardsSetJSON] = []

        let data = try? Data(contentsOf: jsonPath())
        if let data, let value = try? JSONDecoder().decode([FlashcardsSetJSON].self, from: data) {
            json = value
        }

        guard let database = connection else {
            return
        }
        do {
            try database.transaction {
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
                            flashcardsDifficulty <- Int64(flashcard.gameData.difficulty),
                            flashcardsFront <- flashcard.front,
                            flashcardsBack <- flashcard.back
                        ))
                    }
                }
            }
        } catch {
            print("Error migrating JSON to database: \(error)")
        }
    }

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
        } catch {
            print("Error inserting set \(name): \(error)")
        }

        return id
    }

    /// Load all sets
    func loadSets() {
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
            print("Error inserting keyword: \(error)")
        }

        return id
    }

    /// Update a keyword in the database
    func renameKeyword(id: Int64, name: String) {
        guard let database = connection else {
            return
        }
        do {
            try database.run(tableKeywords.filter(columnID == id).update(columnName <- name))
        } catch {
            print("Error updating keyword \(id): \(error)")
        }
    }

    /// Delete a keyword from the database
    func deleteKeyword(id: Int64) {
        guard let database = connection else {
            return
        }
        do {
            try database.run(tableKeywords.filter(columnID == id).delete())
        } catch {
            print("Error deleting keyword \(id): \(error)")
        }
    }

    /// Load keywords from set
    /// - Returns: The keyword ids
    func loadKeywords(fromSet: Int64) -> [Int64] {
        var keywords: [Int64] = []

        guard let database = connection else {
            return keywords
        }
        do {
            for item in try database.prepare(tableKeywords.join(
                tableSetsKeywords,
                on: setsKeywordsKeyword == tableKeywords[columnID] && tableKeywords[columnID] == fromSet
            )) {
                keywords.append(item[tableKeywords[columnID]])
            }
        } catch {
            print("Error loading keywords for set \(fromSet): \(error)")
        }

        return keywords
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
            print("Error identifying keyword id: \(error)")
        }

        return id
    }

}
