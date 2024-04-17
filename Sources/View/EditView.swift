//
//  EditView.swift
//  Memorize
//

import Adwaita

struct EditView: View {

    @Binding var set: FlashcardsSet
    @Binding var editMode: Bool
    @Binding var editSearch: Search
    @Binding var searchFocused: Bool
    @Binding var importText: String
    @Binding var createSet: Bool
    @State private var expanded = false
    @State private var focusedFront: String?
    @State private var focusFront: Signal = .init()
    @State private var importFlashcards = false
    var window: GTUIWindow
    var app: GTUIApp

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
                .focused($searchFocused)
                .padding(5, .horizontal.add(.bottom))
                .frame(maxWidth: 300)
        }
        .topToolbar {
            HeaderBar(titleButtons: false) {
                Toggle(icon: .default(icon: .editFind), isOn: .init {
                    editSearch.visible
                } set: { newValue in
                    editSearch.visible = newValue
                    if newValue {
                        searchFocused.toggle()
                    }
                })
                .tooltip(Loc.searchTitle)
            } end: {
                Button(createSet ? Loc.create : Loc.done) {
                    editMode = false
                    createSet = false
                }
                .style("suggested-action")
            }
            .headerBarTitle {
                WindowTitle(subtitle: "", title: createSet ? Loc.newSet : Loc.editSet)
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
        ForEach(.init(set.flashcards.indices)) { index in
            if let flashcard = set.flashcards[safe: index],
            flashcard.front.search(editSearch.effectiveQuery) || flashcard.back.search(editSearch.effectiveQuery) {
                EditFlashcardView(
                    flashcard: .init {
                        set.flashcards[safe: index] ?? .init()
                    } set: { newValue in
                        if !searchFocused {
                            set.flashcards[safe: index] = newValue
                        }
                    },
                    index: index,
                    tags: set.tags.nonOptional,
                    focusedFront: focusedFront,
                    focusFront: focusFront
                ) {
                    if let flashcard = set.flashcards[safe: index + 1] {
                        focusedFront = flashcard.id
                        focusFront.signal()
                    } else {
                        appendFlashcard()
                    }
                } delete: {
                    set.flashcards = set.flashcards.filter { $0.id != flashcard.id }
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
        .dialog(visible: $importFlashcards, width: 400, height: 450) {
            ImportView(set: $set, text: $importText, window: window, app: app) { importFlashcards = false }
        }
    }

    func appendFlashcard() {
        let flashcard = Flashcard()
        set.flashcards.append(flashcard)
        Task {
            try? await Task.sleep(nanoseconds: 100)
            focusedFront = flashcard.id
            focusFront.signal()
        }
    }

}
