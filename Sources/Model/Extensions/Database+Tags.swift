//
//  Database+Tags.swift
//  Memorize
//

import SQLite

extension Database {

    /// Insert tag, if non-existent for set
    /// - Returns: The id of the tag
    func addTag(tag: String, inSet: Int64) -> Int64 {
        var id = tagID(tag: tag, inSet: inSet)

        guard let database = connection else {
            return id
        }
        do {
            if id == 0 {
                id = try database.run(tableTags.insert(columnName <- tag))
            }
        } catch {
            print("Error inserting tag: \(error)")
        }

        return id
    }

    /// Update a tag in the database
    func renameTag(id: Int64, name: String) {
        guard let database = connection else {
            return
        }
        do {
            try database.run(tableTags.filter(columnID == id).update(columnName <- name))
        } catch {
            print("Error updating tag \(id): \(error)")
        }
    }

    /// Delete a tag from the database
    func deleteTag(id: Int64) {
        guard let database = connection else {
            return
        }
        do {
            try database.run(tableTags.filter(columnID == id).delete())
        } catch {
            print("Error deleting tag \(id): \(error)")
        }
    }

    /// Find tag in tags table for set
    /// - Returns: The id of the tag
    func tagID(tag: String, inSet: Int64) -> Int64 {
        var id: Int64 = 0

        guard let database = connection else {
            return id
        }
        do {
            for item in try database.prepare(tableTags.filter(columnName == tag && tagsSet == inSet)) {
                id = item[columnID]
            }
        } catch {
            print("Error identifying tag id: \(error)")
        }

        return id
    }

}
