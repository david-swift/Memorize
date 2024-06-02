//
//  SearchFlashcardsView.swift
//  Memorize
//

import Adwaita

struct SearchFlashcardsView: View {

    @Binding var editSearch: Search
    @Binding var focusedFront: String?
    @Binding var focusFront: Signal
    var flashcards: [Flashcard]

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
                                editSearch.visible = false
                                focusedFront = flashcard.id
                                focusFront.signal()
                            }
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
