//
//  ToolbarView.swift
//  Flashcards
//

import Adwaita

struct ToolbarView: View {

    @Binding var sidebarVisible: Bool
    @Binding var flashcardsView: FlashcardsView
    @Binding var sets: [FlashcardsSet]
    @Binding var selectedSet: String
    @Binding var filter: String?
    var app: GTUIApp
    var window: GTUIApplicationWindow

    var view: Body {
        HeaderBar {
            Button(icon: .default(icon: .listAdd)) {
                let newSet = FlashcardsSet()
                sets.insert(newSet, at: 0)
                selectedSet = newSet.id
            }
        } end: {
            Menu(icon: .default(icon: .openMenu), app: app, window: window) {
                MenuButton("New Window", window: false) {
                    app.addWindow("main")
                }
                .keyboardShortcut("n".ctrl())
                MenuButton("Close Window") {
                    window.close()
                }
                .keyboardShortcut("w".ctrl())
                viewMenu
                MenuSection {
                    MenuButton("About", window: false) {
                        app.addWindow("about", parent: window)
                    }
                }
            }
        }
        .headerBarTitle {
            Text("Sets")
                .style("heading")
        }
    }

    @ViewBuilder var content: Body {
        HeaderBar.start {
            Toggle(icon: .default(icon: .sidebarShow), isOn: $sidebarVisible)
        }
        .headerBarTitle {
            if sets.contains(where: { $0.id == selectedSet }) {
                ViewSwitcher(selection: $flashcardsView)
                    .wideDesign()
                    .transition(.crossfade)
            }
        }
    }

    var viewMenu: MenuSection {
        .init {
            Submenu("View") {
                for (index, view) in FlashcardsView.allCases.enumerated() {
                    MenuButton(view.title) {
                        flashcardsView = view
                    }
                    .keyboardShortcut("\(index + 1)".alt())
                }
            }
            MenuButton("Filter") {
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
