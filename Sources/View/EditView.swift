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
    @State private var searchFlashcards: [Flashcard] = []
    @State private var stack: NavigationStack<EditNavigationDestination> = .init()
    var window: GTUIWindow
    var app: GTUIApp
    var deleteSet: () -> Void

    var view: Body {
        NavigationView($stack, Loc.editSet) { destination in
            tagView(destination: destination)
        } initialView: {
            VStack {
                if editSearch.visible {
                    FlashcardsListView(flashcards: searchFlashcards) { flashcard in
                        editSearch.visible = false
                        focusedFront = flashcard.id
                        focusFront.signal()
                    }
                    .transition(.crossfade)
                } else {
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
                    .transition(.crossfade)
                }
            }
            .topToolbar(visible: editSearch.visible) { searchToolbar }
            .topToolbar { toolbar }
        }
        .inspect { storage in
            if editSearch.effectiveQuery.isEmpty {
                guard editSearch.visible else {
                    return
                }
                if set.flashcards.map({ $0.id }) != searchFlashcards.map({ $0.id }) {
                    Idle {
                        searchFlashcards = set.flashcards
                    }
                }
            } else if !(storage.fields["idle-update"] as? Bool ?? false) {
                (storage.fields["current-task"] as? Task<Void, Never>)?.cancel()
                storage.fields["current-task"] = Task {
                    let searchFlashcards = set.flashcards.search(query: editSearch)
                    Idle {
                        self.searchFlashcards = searchFlashcards
                        storage.fields["idle-update"] = true
                    }
                }
            } else {
                storage.fields["idle-update"] = false
            }
        }
    }

    var toolbar: View {
        HeaderBar(titleButtons: false) {
            if createSet {
                Button(Loc.cancel) {
                    editMode = false
                    createSet = false
                    deleteSet()
                }
            } else {
                Toggle(icon: .default(icon: .editFind), isOn: .init {
                    editSearch.visible
                } set: { newValue in
                    editSearch.visible = newValue
                    if newValue {
                        searchFocused.toggle()
                    }
                })
                .tooltip(Loc.searchTitle)
            }
        } end: {
            Button(createSet ? Loc.create : Loc.done) {
                editMode = false
                createSet = false
            }
            .suggested()
        }
        .headerBarTitle {
            WindowTitle(subtitle: "", title: createSet ? Loc.newSet : Loc.editSet)
        }
    }

    var searchToolbar: View {
        SearchEntry()
            .placeholderText(Loc.searchFlashcards)
            .text($editSearch.query)
            .stopSearch {
                editSearch.visible = false
            }
            .focused($searchFocused)
            .padding(5, .horizontal.add(.bottom))
            .frame(maxWidth: 300)
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
                element: Loc.tag,
                stack: $stack,
                flashcards: set.flashcards
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
            if let flashcard = set.flashcards[safe: index] {
                EditFlashcardView(
                    flashcard: .init { set.flashcards[safe: index] ?? .init() } set: { newValue in
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
                        Idle {
                            focusedFront = set.flashcards[safe: index - 1]?.id
                            focusedFront = nil
                        }
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
            Idle {
                focusedFront = flashcard.id
                focusFront.signal()
            }
        }
    }

    func toggleTag(flashcard: Flashcard, tag: String) {
        if flashcard.tags.nonOptional.contains(tag) {
            set.flashcards[
                safe: set.flashcards.firstIndex { $0.id == flashcard.id }
            ]?.tags = flashcard.tags.nonOptional.filter { $0 != tag }
        } else {
            set.flashcards[safe: set.flashcards.firstIndex { $0.id == flashcard.id }]?.tags.nonOptional.append(tag)
        }
    }

    func tagView(destination: EditNavigationDestination) -> View {
        FlashcardsListView(flashcards: set.flashcards) { flashcard in
            guard case let .tag(tag) = destination else {
                return
            }
            toggleTag(flashcard: flashcard, tag: tag)
        } prefix: { flashcard in
            if case let .tag(tag) = destination {
                CheckButton()
                    .active(.init {
                        flashcard.tags.nonOptional.contains(tag)
                    } set: { newValue in
                        if newValue {
                            if !flashcard.tags.nonOptional.contains(tag) {
                                toggleTag(flashcard: flashcard, tag: tag)
                            }
                        } else {
                            if flashcard.tags.nonOptional.contains(tag) {
                                toggleTag(flashcard: flashcard, tag: tag)
                            }
                        }
                    })
                    .style("selection-mode")
                    .valign(.center)
            } else {
                CheckButton()
            }
        }
        .topToolbar {
            HeaderBar()
        }
    }

}
