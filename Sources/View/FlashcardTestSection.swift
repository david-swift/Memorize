//
//  FlashcardTestSection.swift
//  Flashcards
//

import Adwaita

struct FlashcardTestSection: View {

    @Binding var flashcard: Flashcard

    var view: Body {
        VStack {
            if let lastInput = flashcard.gameData.lastInput {
                if lastInput == flashcard.back {
                    Form {
                        front
                        back
                            .style("success")
                    }
                } else {
                    Form {
                        front
                            .suffix {
                                Button(icon: .default(icon: .emojiObjects)) {
                                    flashcard.gameData.input = flashcard.back
                                }
                                .style("flat")
                                .verticalCenter()
                            }
                        back
                            .style("error")
                    }
                }
            } else {
                Form {
                    front
                    back
                }
            }
        }
        .padding(10, .vertical)
    }

    var front: ActionRow {
        .init(flashcard.front)
    }

    var back: View {
        EntryRow(Loc.answer, text: $flashcard.gameData.input)
    }

}
