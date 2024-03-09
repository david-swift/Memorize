//
//  ToolbarView.swift
//  Memorize
//

import Adwaita

struct ToolbarView: View {

    @Binding var flashcardsView: FlashcardsView
    @Binding var sets: [FlashcardsSet]
    @Binding var selectedSet: String
    @Binding var filter: String?
    var app: GTUIApp
    var window: GTUIApplicationWindow
    var addSet: () -> Void

    var view: Body {
        HeaderBar {
            Button(icon: .default(icon: .listAdd)) {
                addSet()
            }
            .tooltip(Loc.addSet)
        } end: {
            if flashcardsView == .overview && !sets.isEmpty {
                menu
            }
        }
        .headerBarTitle {
            Text(Loc.sets)
                .style("heading")
        }
    }

    @ViewBuilder var content: Body {
        HeaderBar.end {
            if flashcardsView != .overview || sets.isEmpty {
                menu
            }
        }
        .headerBarTitle {
            if sets.contains(where: { $0.id == selectedSet }) {
                ViewSwitcher(selection: $flashcardsView)
                    .wideDesign()
                    .transition(.crossfade)
            } else {
                []
            }
        }
    }

    var menu: View {
        Menu(icon: .default(icon: .openMenu), app: app, window: window) {
            MenuButton(Loc.newWindow, window: false) {
                app.addWindow("main")
            }
            .keyboardShortcut("n".ctrl())
            MenuButton(Loc.closeWindow) {
                window.close()
            }
            .keyboardShortcut("w".ctrl())
            viewMenu
            MenuSection {
                MenuButton(Loc.about, window: false) {
                    app.addWindow("about", parent: window)
                }
            }
        }
        .primary()
        .tooltip(Loc.mainMenu)
    }

    var viewMenu: MenuSection {
        .init {
            Submenu(Loc.viewMenu) {
                for (index, view) in FlashcardsView.allCases.enumerated() {
                    MenuButton(view.title) {
                        flashcardsView = view
                    }
                    .keyboardShortcut("\(index + 1)".alt())
                }
            }
            if flashcardsView == .overview {
                MenuButton(Loc.filter) {
                    if filter != nil {
                        filter = nil
                    } else {
                        filter = ""
                    }
                }
                .keyboardShortcut("f".ctrl())
            }
        }
    }

}
