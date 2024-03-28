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

    init() {
        sets = []
        print("Check JSON file, maybe create new one if not available")
        checkFile()
        print("Read value from JSON file")
        readValue()

        do {
            let database = try Connection(databasePath().path)

            checkDatabase(database)
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

    /// Check whether the settings file exists, and, if not, create it.
    private func checkFile() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dirPath().path) {
            try? fileManager.createDirectory(
                at: .init(fileURLWithPath: dirPath().path),
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        if !fileManager.fileExists(atPath: filePath().path) {
            fileManager.createFile(atPath: filePath().path, contents: .init(), attributes: nil)
        }
    }

    // Check whether the database file exists, and, if not, initialize it.
    private func checkDatabase(_ database: Connection) {
        do {
            let setsTable = Table("sets")
            let flashcardsTable = Table("flashcards")

            // sets table layout
            let setsId = Expression<Int64>("id")
            let setsName = Expression<String>("name")
            let answerSide = Expression<String>("answerSide")

            try database.run(setsTable.create(ifNotExists: true) { table in
                table.column(setsId, primaryKey: .autoincrement)
                table.column(setsName)
                table.column(answerSide)
                table.check(answerSide == "front" || answerSide == "back")
            })

            // flashcards table layout
            let flashcardsId = Expression<Int64>("id")
            let difficulty = Expression<Int64>("difficulty")
            let front = Expression<String?>("front")
            let back = Expression<String?>("back")

            try database.run(flashcardsTable.create(ifNotExists: true) { table in
                table.column(flashcardsId, primaryKey: .autoincrement)
                table.column(difficulty)
                table.column(front)
                table.column(back)
            })
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
