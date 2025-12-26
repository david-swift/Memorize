//
//  AnyView.swift
//  Memorize
//

import Adwaita

extension AnyView {

    func formWidth() -> AnyView {
        frame(maxWidth: 500)
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
