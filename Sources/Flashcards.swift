//
//  Flashcards.swift
//  Flashcards
//

import Adwaita

@main
struct Flashcards: App {

    @State("sets", folder: "io.github.david_swift.Flashcards")
    private var sets: [FlashcardsSet] = []
    let id = "io.github.david_swift.Flashcards"
    var app: GTUIApp!

    var scene: Scene {
        Window(id: "main") { window in
            ContentView(sets: $sets, app: app, window: window)
        }
        .defaultSize(width: 700, height: 550)
        .quitShortcut()
        .overlay {
            AboutWindow(id: "about", appName: "Flashcards", developer: "david-swift", version: "0.1.0")
                .icon(.custom(name: "io.github.david_swift.Flashcards"))
                .website(.init(string: "https://github.com/david-swift/Flashcards"))
            for (index, set) in sets.enumerated() {
                Window(id: "import-\(set.id)", open: 0) { window in
                    ImportView(set: .init {
                        set
                    } set: { newValue in
                        sets[safe: index] = newValue
                    }, window: window)
                }
                .title("Import Flashcards")
                .defaultSize(width: 500, height: 500)
                .keyboardShortcut("Escape") { $0.close() }
            }
        }
    }

}
