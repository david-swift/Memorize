//
//  ToolbarView.swift
//  Memorize
//

import Adwaita

struct ToolbarView: View {

    @Binding var sets: [FlashcardsSet]
    @Binding var selectedSet: String
    @Binding var search: Search
    @Binding var editSearch: Search
    @Binding var searchFocused: Bool
    @Binding var editMode: Bool
    @State private var about = false
    @State private var shortcuts = false
    var app: AdwaitaApp
    var addSet: () -> Void

    var view: Body {
        content
            .shortcutsDialog(visible: $shortcuts)
            .shortcutsSection("General") { section in
                section
                    .shortcutsItem(Loc.closeWindow, accelerator: "w".ctrl())
                    .shortcutsItem(Loc.quit, accelerator: "q".ctrl())
                    .shortcutsItem(Loc.openMenu, accelerator: "F10")
                    .shortcutsItem(Loc.keyboardShortcuts, accelerator: "question".ctrl())
            }
            .shortcutsSection(Loc.sets) { section in
                section
                    .shortcutsItem(Loc.newSet, accelerator: "n".ctrl())
                    .shortcutsItem(Loc.deleteSet, accelerator: "Delete")
                    .shortcutsItem(Loc.exportSet, accelerator: "e".ctrl())
                    .shortcutsItem(Loc.searchSets, accelerator: "f".ctrl())
            }
    }

    @ViewBuilder var content: Body {
        HeaderBar {
            Button(icon: .default(icon: .listAdd)) {
                addSet()
            }
            .keyboardShortcut("n".ctrl())
            .tooltip(Loc.addSet)
        } end: {
            menu
        }
        .headerBarTitle {
            Text(Loc.sets)
                .heading()
        }
        .aboutDialog(
            visible: $about,
            app: "Memorize",
            developer: "david-swift",
            version: "0.2.6",
            icon: .custom(name: "io.github.david_swift.Flashcards"),
            website: .init(string: "https://github.com/david-swift/Memorize"),
            issues: .init(string: "https://github.com/david-swift/Memorize/issues")
        )
    }

    var menu: AnyView {
        Menu(icon: .default(icon: .openMenu)) {
            viewMenu
            MenuSection {
                MenuButton(Loc.keyboardShortcuts, window: false) {
                    shortcuts = true
                }
                .keyboardShortcut("question".ctrl())
                MenuButton(Loc.about, window: false) {
                    about = true
                }
            }
        }
        .primary()
        .tooltip(Loc.mainMenu)
    }

    var viewMenu: MenuSection {
        .init {
            MenuButton(Loc.search) {
                if editMode {
                    editSearch.toggle()
                    if editSearch.visible {
                        searchFocused = true
                    }
                } else {
                    search.toggle()
                    if search.visible {
                        searchFocused = true
                    }
                }
            }
            .keyboardShortcut("f".ctrl())
        }
    }

}
