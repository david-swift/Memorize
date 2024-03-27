//
//  Array.swift
//  Memorize
//

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

extension Array where Element: SearchScore {

    func sortScore(_ search: String) -> Self {
        map { ($0, $0.score(search)) }.sorted { $0.1 > $1.1 }.filter { $0.1 != 0 }.map { $0.0 }
    }

}
