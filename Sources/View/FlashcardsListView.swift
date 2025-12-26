//
//  FlashcardsListView.swift
//  Memorize
//

import Adwaita

struct FlashcardsListView: SimpleView {

    var flashcards: [Flashcard]
    var activated: (Flashcard) -> Void
    var prefix: (Flashcard) -> AnyView = { _ in [] }

    var view: Body {
        ScrollView {
            List(flashcards, selection: nil) { flashcard in
                ActionRow()
                    .title(flashcard.front)
                    .subtitle(flashcard.back)
                    .useMarkup(false)
                    .activatableWidget {
                        Button()
                            .activate {
                                activated(flashcard)
                            }
                    }
                    .prefix {
                        prefix(flashcard)
                    }
            }
            .boxedList()
            .padding(20)
            .frame(maxWidth: 600)
            .valign(.start)
        }
        .vexpand()
    }

}
