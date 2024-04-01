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
