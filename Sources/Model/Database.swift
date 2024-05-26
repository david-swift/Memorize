//
//  Database.swift
//  Memorize
//

import Adwaita
import Foundation
import SQLite

class Database {

    var sets: [FlashcardsSet]

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
    let setsKeywordsSet = Expression<Int64>("sets_id") // Foreign Key: sets[id]
    let setsKeywordsKeyword = Expression<Int64>("keywords_id") // Foreign Key: keywords[id]

    // Tags Table types
    let tableTags = Table("tags")
    /* id: columnID */
    /* name: columnName */
    let tagsSet = Expression<Int64>("sets_id") // Foreign Key: sets[id]

    // Flashcards to Tags Table types
    let tableFlashcardsTags = Table("flashcards_tags")
    /* id: columnID */
    let flashcardsTagsFlashcard = Expression<Int64>("flashcards_id") // Foreign Key: flashcards[id]
    let flashcardsTagsTag = Expression<Int64>("tags_id") // Foreign Key: tags[id]

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
            // swiftlint:disable closure_body_length
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

                // Tags Table
                try database.run(tableTags.create(ifNotExists: true) { table in
                    table.column(columnID, primaryKey: .autoincrement)
                    table.column(columnName)
                    table.column(tagsSet, references: tableSets, columnID)
                })

                // Sets to Keywords Table
                try database.run(tableFlashcardsTags.create(ifNotExists: true) { table in
                    table.column(columnID, primaryKey: .autoincrement)
                    table.column(flashcardsTagsFlashcard, references: tableFlashcards, columnID)
                    table.column(flashcardsTagsTag, references: tableTags, columnID)
                })
            }
            // swiftlint:enable closure_body_length
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
            var setid: Int64 = 0
            var cardid: Int64 = 0
            var tagid: Int64 = 0

            // swiftlint:disable closure_body_length
            try database.transaction {
                for item in json {
                    print("Migrate set " + item.name)

                    setid = try database.run(tableSets.insert(
                        columnName <- item.name,
                        setsSide <- item.answerSide.rawValue
                    ))

                    for keyword in item.keywords.nonOptional {
                        try database.run(tableSetsKeywords.insert(
                            setsKeywordsSet <- Int64(setid),
                            setsKeywordsKeyword <- addKeyword(keyword)
                        ))
                    }

                    for flashcard in item.flashcards {
                        cardid = try database.run(tableFlashcards.insert(
                            flashcardsSet <- Int64(setid),
                            flashcardsDifficulty <- Int64(flashcard.gameData.difficulty),
                            flashcardsFront <- flashcard.front,
                            flashcardsBack <- flashcard.back
                        ))
                        for tag in flashcard.tags.nonOptional {
                            tagid = try database.run(tableTags.insert(
                                columnName <- tag,
                                tagsSet <- setid
                            ))
                            try database.run(tableFlashcardsTags.insert(
                                flashcardsTagsFlashcard <- cardid,
                                flashcardsTagsTag <- tagid
                            ))
                        }
                    }
                }
            }
            // swiftlint:enable closure_body_length
        } catch {
            print("Error migrating JSON to database: \(error)")
        }
    }

}
