//
//  Database.swift
//  Memorize
//

import Adwaita
import Foundation

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
