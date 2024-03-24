//
//  EditView.swift
//  Memorize
//

import Adwaita

struct EditView: View {

    @Binding var set: FlashcardsSet
    @Binding var editMode: Bool
    @Binding var editSearch: Search
    @State private var expanded = false
    @State private var focusedFront: String?
    @State private var importFlashcards = false

    var view: Body {
        ScrollView {
            VStack {
                title
                tags
                flashcards
                actions
            }
            .formWidth()
        }
        .vexpand()
        .topToolbar(visible: editSearch.visible) {
            SearchEntry()
                .placeholderText(Loc.searchFlashcards)
                .text($editSearch.query)
                .focused(.constant(editSearch.visible))
                .padding(5, .horizontal.add(.bottom))
                .frame(maxWidth: 300)
        }
        .topToolbar {
            HeaderBar(titleButtons: false) {
                Toggle(icon: .default(icon: .editFind), isOn: $editSearch.visible)
                    .tooltip(Loc.searchTitle)
            } end: {
                Button(Loc.done) {
                    editMode = false
                }
                .style("suggested-action")
            }
            .headerBarTitle {
                WindowTitle(subtitle: "", title: Loc.editSet)
            }
        }
    }

    var title: View {
        Form {
            EntryRow(Loc.title, text: $set.name)
            KeywordsRow(keywords: $set.keywords.nonOptional)
        }
        .padding(20)
    }

    var tags: View {
        Form {
            KeywordsRow(
                keywords: $set.tags.nonOptional,
                title: Loc.tags,
                subtitle: Loc.tagsDescription,
                element: Loc.tag
            )
            SwitchRow()
                .title(Loc.star)
                .subtitle(Loc.starDescription)
                .active(
                    .init {
                        set.tags.nonOptional.contains(Localized.star.en) ||
                        set.tags.nonOptional.contains(Localized.star.de)
                    } set: { newValue in
                        if newValue && !(
                            set.tags.nonOptional.contains(Localized.star.en) ||
                            set.tags.nonOptional.contains(Localized.star.de)
                        ) {
                            set.tags.nonOptional.append(Loc.star)
                        } else {
                            set.tags.nonOptional = set.tags.nonOptional
                                .filter { $0 != Localized.star.en && $0 != Localized.star.de }
                        }
                    }
                )
        }
        .padding(20)
    }

    var flashcards: View {
        var cards: [Flashcard] = set.flashcards.sortScore(editSearch.query)

        return ForEach(.init(cards.indices)) { index in
            if cards[safe: index] != nil {
                EditFlashcardView(
                    flashcard: .init {
                        cards[safe: index] ?? .init()
                    } set: { newValue in
                        cards[safe: index] = newValue
                    },
                    index: index,
                    tags: set.tags.nonOptional,
                    focusedFront: focusedFront
                ) {
                    if let flashcard = cards[safe: index + 1] {
                        focusedFront = flashcard.id
                        focusedFront = nil
                    } else {
                        appendFlashcard()
                    }
                } delete: {
                    let localCards = cards.filter { $0.id != cards[safe: index]?.id }
                    cards = localCards
                    Task {
                        try? await Task.sleep(nanoseconds: 100)
                        focusedFront = localCards[safe: index - 1]?.id
                        focusedFront = nil
                    }
                }
            }
        }
        .padding()
    }

    var actions: View {
        PillButtonSet(
            primary: Loc.addFlashcard,
            icon: .default(icon: .listAdd),
            secondary: Loc.importFlashcards,
            icon: .custom(name: "io.github.david_swift.Flashcards.import-symbolic")
        ) {
            appendFlashcard()
        } secondary: {
            importFlashcards = true
        }
        .dialog(visible: $importFlashcards, width: 400, height: 500) {
            ImportView(set: $set) { importFlashcards = false }
        }
    }

    func appendFlashcard() {
        let flashcard = Flashcard()
        set.flashcards.append(flashcard)
        Task {
            try? await Task.sleep(nanoseconds: 100)
            focusedFront = flashcard.id
            focusedFront = nil
        }
    }

}
