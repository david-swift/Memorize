//
//  Database+Keywords.swift
//  Memorize
//

import SQLite

extension Database {

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
