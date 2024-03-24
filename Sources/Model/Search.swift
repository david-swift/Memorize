//
//  Search.swift
//  Memorize
//

protocol SearchScore {

    func score(_ query: String?) -> Int
}

func search(_ search: String, in text: String) -> Bool {
    guard !search.isEmpty else {
        return true
    }
    var remainder = search.lowercased()[...]
    for char in text.lowercased() where char == remainder[remainder.startIndex] {
        remainder.removeFirst()
        if remainder.isEmpty {
            return true
        }
    }
    return false
}

func sortScore(_ search: String, in structArray: [any SearchScore]) -> [any SearchScore] {
    structArray.map { ($0, $0.score(search)) }.sorted { $0.1 > $1.1 }.filter { $0.1 != 0 }.map { $0.0 }
}
