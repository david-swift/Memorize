//
//  Array.swift
//  Memorize
//

import Adwaita
import FuzzyFind

extension Array where Element == FlashcardsSet {

    /// The keywords.
    var keywords: [String] {
        var keywords: Set<String> = []
        for set in self {
            keywords.formUnion(set.keywords.nonOptional)
        }
        return .init(keywords)
    }

}

extension Array where Element: Searchable {

    func search(query: Search) -> Self {
        map { (value: $0, score: bestMatch(query: query.effectiveQuery, input: $0.searchString)?.score.value ?? 0) }
            .filter { $0.score > 0 || query.effectiveQuery.isEmpty }
            .sorted { $0.score > $1.score }
            .map { $0.value }
    }

}
