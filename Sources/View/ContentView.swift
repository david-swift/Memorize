//
//  ContentView.swift
//  Flashcards
//

import Adwaita
import Foundation

struct ContentView: View {

    @Binding var sets: [FlashcardsSet]
    @State("selected-set")
    private var selectedSet = ""
    @State private var sidebarVisible = true
    @State("flashcards-view")
    private var flashcardsView: FlashcardsView = .overview
    var app: GTUIApp
    var window: GTUIApplicationWindow

    var view: Body {
        OverlaySplitView(visible: $sidebarVisible) {
            sidebar
        } content: {
            content
                .topToolbar {
                    ToolbarView(
                        sidebarVisible: $sidebarVisible,
                        flashcardsView: $flashcardsView,
                        sets: $sets,
                        selectedSet: $selectedSet,
                        app: app,
                        window: window
                    ).content
                }
        }
    }

    var sidebar: View {
        ScrollView {
            List(sets, selection: $selectedSet) { set in
                Text(set.name)
                    .padding()
                    .halign(.start)
            }
            .style("navigation-sidebar")
        }
        .hexpand()
        .topToolbar {
            ToolbarView(
                sidebarVisible: $sidebarVisible,
                flashcardsView: $flashcardsView,
                sets: $sets,
                selectedSet: $selectedSet,
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
                SetOverview(set: binding, app: app, window: window)
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

}
