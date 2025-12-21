//
//  String.swift
//  Memorize
//

extension String: @retroactive Identifiable {

    /// The identifier.
    public var id: Self { self }

    func search(_ search: String) -> Bool {
        guard !search.isEmpty else {
            return true
        }
        var remainder = search.lowercased()[...]
        for char in lowercased() where char == remainder[remainder.startIndex] {
            remainder.removeFirst()
            if remainder.isEmpty {
                return true
            }
        }
        return false
    }

}
