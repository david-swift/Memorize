//
//  EditView.swift
//  Memorize
//

import Adwaita

struct EditView: View {

    @Binding var set: FlashcardsSet
    @Binding var editMode: Bool
    @State private var expanded = false
    @State private var focusedFront: String?
    @State private var importFlashcards = false
    @State private var searchQuery: String = ""

    var view: Body {
        ScrollView {
            VStack {
                title
                tags
                search
                flashcards
                actions
            }
            .formWidth()
        }
        .vexpand()
        .topToolbar {
            HeaderBar(titleButtons: false) {
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

    var search: View {
        FormSection(Loc.searchTitle) {
            Form {
                EntryRow(Loc.searchFlashcards, text: $searchQuery)
            }
        }
        .padding(20)
    }

    var flashcards: View {
        ForEach(.init(set.flashcards.indices)) { index in
            if set.flashcards[safe: index] != nil {
                EditFlashcardView(
                    flashcard: .init {
                        set.flashcards[safe: index] ?? .init()
                    } set: { newValue in
                        set.flashcards[safe: index] = newValue
                    },
                    index: index,
                    tags: set.tags.nonOptional,
                    focusedFront: focusedFront
                ) {
                    if let flashcard = set.flashcards[safe: index + 1] {
                        focusedFront = flashcard.id
                        focusedFront = nil
                    } else {
                        appendFlashcard()
                    }
                } delete: {
                    set.flashcards = set.flashcards.filter { $0.id != set.flashcards[safe: index]?.id }
                    Task {
                        try? await Task.sleep(nanoseconds: 100)
                        focusedFront = set.flashcards[safe: index - 1]?.id
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
