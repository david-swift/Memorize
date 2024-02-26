//
//  ContentView.swift
//  Flashcards
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
        OverlaySplitView(visible: .constant(flashcardsView == .overview && !editMode)) {
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
                        window: window
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
                    .padding()
                    .halign(.start)
            }
            .style("navigation-sidebar")
        }
        .hexpand()
        .topToolbar(visible: filter != nil) {
            SearchEntry()
                .placeholderText("Filter Sets")
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
                window: window
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
                "No Selection",
                icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
                description: "Select a set in the sidebar."
            )
            .centerMinSize()
        } else {
            StatusPage(
                "No Sets",
                icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
                description: "Create a new set using the <b>+</b> button in the sidebar."
            )
            .centerMinSize()
        }
    }

    func window(_ window: Window) -> Window {
        window
            .size(width: $width, height: $height)
    }

}
