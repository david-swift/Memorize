//
//  ContentView.swift
//  Memorize
//

import Adwaita
import CAdw
import Foundation

struct ContentView: WindowView {

    @Binding var sets: [FlashcardsSet]
    @State("selected-set")
    private var selectedSet = ""
    @State("flashcards-view")
    private var flashcardsView: FlashcardsView = .overview
    @State private var filter: String?
    @State private var editMode = false
    @State("width")
    private var width = 700
    @State("height")
    private var height = 550
    var app: GTUIApp
    var window: GTUIApplicationWindow

    var view: Body {
        OverlaySplitView(visible: .constant(flashcardsView == .overview && !editMode && !sets.isEmpty)) {
            sidebar
        } content: {
            content
                .topToolbar(visible: !editMode || flashcardsView != .overview) {
                    ToolbarView(
                        flashcardsView: $flashcardsView,
                        sets: $sets,
                        selectedSet: $selectedSet,
                        filter: $filter,
                        app: app,
                        window: window,
                        addSet: addSet
                    ).content
                }
        }
    }

    var sidebar: View {
        ScrollView {
            List(
                sets.map { ($0, $0.score(filter)) }.sorted { $0.1 > $1.1 }.filter { $0.1 != 0 }.map { $0.0 },
                selection: $selectedSet
            ) { set in
                Text(set.name)
                    .inspectOnAppear { gtk_label_set_ellipsize($0.pointer, PANGO_ELLIPSIZE_END) }
                    .padding()
                    .halign(.start)
            }
            .style("navigation-sidebar")
        }
        .hexpand()
        .topToolbar(visible: filter != nil) {
            SearchEntry()
                .placeholderText(Loc.filterSets)
                .text(.init { filter ?? "" } set: { filter = $0 })
                .focused(.constant(!editMode && flashcardsView == .overview))
                .padding(5, .horizontal.add(.bottom))
        }
        .topToolbar {
            ToolbarView(
                flashcardsView: $flashcardsView,
                sets: $sets,
                selectedSet: $selectedSet,
                filter: $filter,
                app: app,
                window: window,
                addSet: addSet
            )
        }
    }

    @ViewBuilder var content: Body {
        if let index = sets.firstIndex(where: { $0.id == selectedSet }), let set = sets[safe: index] {
            let binding = Binding<FlashcardsSet> { sets[safe: index] ?? .init() } set: { sets[safe: index] = $0 }
            switch flashcardsView {
            case .overview:
                SetOverview(set: binding, editMode: $editMode, app: app, window: window)
            case .study:
                ViewStack(element: set) { _ in
                    StudyView(set: binding)
                }
            case .test:
                TestView(set: binding)
            }
        } else if !sets.isEmpty {
            StatusPage(
                Loc.noSelection,
                icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
                description: Loc.noSelectionDescription
            )
            .centerMinSize()
        } else {
            StatusPage(
                Loc.noSets,
                icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
                description: Loc.noSetsDescription
            ) {
                Button(Loc.createSet) {
                    addSet()
                }
                .style("pill")
                .style("suggested-action")
                .horizontalCenter()
            }
            .centerMinSize()
        }
    }

    func window(_ window: Window) -> Window {
        window
            .size(width: $width, height: $height)
    }

    func addSet() {
        let newSet = FlashcardsSet()
        sets.insert(newSet, at: 0)
        selectedSet = newSet.id
    }

}
