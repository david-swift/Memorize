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
            print("Update in JSON file")
            writeCodableValue()
        }
    }

    // sets table layout
    let setsTable = Table("sets")
    let setsId = Expression<Int64>("id")
    let name = Expression<String>("name")
    let answerSide = Expression<String>("answerSide")

    // flashcards table layout
    let flashcardsTable = Table("flashcards")
    let flashcardsId = Expression<Int64>("id")
    let setsTableId = Expression<Int64>("sets_id")
    let difficulty = Expression<Int?>("difficulty")
    let front = Expression<String?>("front")
    let back = Expression<String?>("back")

    init() {
        sets = []

        do {
            let database = try Connection(databasePath().path)

            print("Check data directory")
            checkDir()

            checkDatabase(database)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath().path) {
                print("Read value from JSON file")
                readValue()

                print("Insert JSON to SQLite")
                insertJSON(database)

                let backupPath = filePath().path + ".bak"
                try fileManager.moveItem(atPath: filePath().path, toPath: backupPath)
                print("Conversion finished. Backup of JSON file at " + backupPath)
            }
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

    /// Get the settings file path.
    /// - Returns: The path.
    private func filePath() -> URL {
        dirPath().appendingPathComponent("sets.json")
    }

    /// Get the settings file path.
    /// - Returns: The path.
    private func databasePath() -> URL {
        dirPath().appendingPathComponent("data.sqlite3")
    }

    /// Check whether the data directory exists, and, if not, create it.
    private func checkDir() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dirPath().path) {
            try? fileManager.createDirectory(
                at: .init(fileURLWithPath: dirPath().path),
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }

    // Check whether the database layout exists, and, if not, create it.
    private func checkDatabase(_ database: Connection) {
        do {
            // sets table rules
            try database.run(setsTable.create(ifNotExists: true) { table in
                table.column(setsId, primaryKey: .autoincrement)
                table.column(name)
                table.column(answerSide)
                table.check(answerSide == "front" || answerSide == "back")
            })

            // flashcards table rules
            try database.run(flashcardsTable.create(ifNotExists: true) { table in
                table.column(flashcardsId, primaryKey: .autoincrement)
                table.column(setsTableId, references: setsTable, setsId)
                table.column(difficulty, defaultValue: 0)
                table.column(front)
                table.column(back)
            })
        } catch {
            print(error)
        }
    }

    // Parse the JSON file (old save format) to the database
    private func insertJSON(_ database: Connection) {
        do {
            for (index, item) in sets.enumerated() {
                try database.run(setsTable.insert(
                    name <- item.name,
                    answerSide <- item.answerSide.rawValue
                ))

                for flashcard in item.flashcards {
                    try database.run(flashcardsTable.insert(
                        setsTableId <- Int64(index + 1),
                        difficulty <- flashcard.gameData.difficulty,
                        front <- flashcard.front,
                        back <- flashcard.back
                    ))
                }
            }
        } catch {
            print(error)
        }
    }

    /// Update the local value with the value from the file.
    private func readValue() {
        let data = try? Data(contentsOf: filePath())
        if let data, let value = try? JSONDecoder().decode([FlashcardsSet].self, from: data) {
            sets = value
        }
    }

    /// Update the value on the file with the local value.
    private func writeCodableValue() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(sets)
        try? data?.write(to: filePath())
    }

}
