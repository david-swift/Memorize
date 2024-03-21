//
//  ToolbarView.swift
//  Memorize
//

import Adwaita

struct ToolbarView: View {

    @Binding var sets: [FlashcardsSet]
    @Binding var selectedSet: String
    @Binding var filter: String?
    @State private var about = false
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
            menu
        }
        .headerBarTitle {
            Text(Loc.sets)
                .style("heading")
        }
        .aboutDialog(
            visible: $about,
            app: "Memorize",
            developer: "david-swift",
            version: "0.2.0",
            icon: .custom(name: "io.github.david_swift.Flashcards"),
            website: .init(string: "https://github.com/david-swift/Memorize"),
            issues: .init(string: "https://github.com/david-swift/Memorize/issues")
        )
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
                    about = true
                }
            }
        }
        .primary()
        .tooltip(Loc.mainMenu)
    }

    var viewMenu: MenuSection {
        .init {
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
