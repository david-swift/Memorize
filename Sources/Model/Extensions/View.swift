//
//  View.swift
//  Flashcards
//

import Adwaita

extension View {

    func formWidth() -> View {
        frame(maxSize: 500)
    }

    @ViewBuilder
    func centerMinSize() -> Body {
        Text("")
            .vexpand()
        self
        Text("")
            .vexpand()
    }

    func section(_ title: String) -> FormSection {
        .init(title) {
            self
        }
    }

}
