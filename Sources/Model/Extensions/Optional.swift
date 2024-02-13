//
//  Optional.swift
//  Flashcards
//

extension Optional where Wrapped == [String] {

    var nonOptional: Wrapped {
        get {
            self ?? .init()
        }
        set {
            self = newValue
        }
    }

}

extension Optional where Wrapped == Bool {

    var nonOptional: Wrapped {
        get {
            self ?? true
        }
        set {
            self = newValue
        }
    }

}

extension Optional where Wrapped == Int {

    var nonOptional: Wrapped {
        get {
            self ?? 1
        }
        set {
            self = newValue
        }
    }

}
