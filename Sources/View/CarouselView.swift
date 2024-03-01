//
//  CarouselView.swift
//  Memorize
//

import Adwaita

struct CarouselView: View {

    @State private var answerCards: [String] = []
    @Binding var set: FlashcardsSet

    var view: Body {
        Carousel(set.flashcards) { flashcard in
            carouselContent(flashcard: flashcard)
                .style("card")
                .padding(20)
                .frame(minWidth: 200, minHeight: 150)
                .onClick {
                    if answerCards.contains(flashcard.id) {
                        answerCards = answerCards.filter { $0 != flashcard.id }
                    } else {
                        answerCards.append(flashcard.id)
                    }
                }
                .frame(maxSize: 350)
                .overlay {
                    starOverlay(flashcard: flashcard)
                }
        }
        .longSwipes()
    }

    func carouselContent(flashcard: Flashcard) -> View {
        VStack {
            if answerCards.contains(flashcard.id) {
                Text(flashcard.back)
                    .transition(.slideUp)
            } else {
                Text(flashcard.front)
                    .transition(.slideDown)
            }
        }
        .modifyContent(Text.self) { text in
            VStack {
                text
                    .wrap()
                    .style("title-3")
                    .valign(.center)
                    .vexpand()
                    .hexpand()
                    .padding()
            }
        }
    }

    func starOverlay(flashcard: Flashcard) -> View {
        VStack {
            HStack {
                TagsButton(
                    selectedTags: .init {
                        flashcard.tags.nonOptional
                    } set: { newValue in
                        set.flashcards[
                            safe: set.flashcards.firstIndex { $0.id == flashcard.id }
                        ]?.tags = newValue
                    },
                    editTags: .constant(false),
                    tags: set.tags.nonOptional,
                    starOnly: true
                )
                .padding(35, .top.add(.trailing))
            }
            .halign(.end)
        }
        .valign(.start)
    }

}
