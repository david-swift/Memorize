//
//  FlashcardTestSection.swift
//  Memorize
//

import Adwaita

struct FlashcardTestSection: SimpleView {

    @Binding var flashcard: Flashcard
    var focusedFlashcard: String?
    var focusFlashcard: Signal
    var focusNext: () -> Void

    var view: Body {
        VStack {
            if let lastInput = flashcard.gameData.lastInput {
                if lastInput == flashcard.back {
                    Form {
                        front
                        back
                            .success()
                    }
                } else {
                    Form {
                        front
                            .suffix {
                                Button(icon: .default(icon: .emojiObjects)) {
                                    flashcard.gameData.input = flashcard.back
                                }
                                .flat()
                                .valign(.center)
                            }
                        back
                            .error()
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
            .useMarkup(false)
    }

    var back: AnyView {
        EntryRow(Loc.answer, text: $flashcard.gameData.input)
            .entryActivated {
                focusNext()
            }
            .focus(focusedFlashcard == flashcard.id ? focusFlashcard : .init())
    }

}
