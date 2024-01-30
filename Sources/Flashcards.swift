//
//  Flashcards.swift
//  Flashcards
//

import Adwaita
import Foundation

@main
struct Flashcards: App {

    @State("sets", folder: "io.github.david_swift.Flashcards", forceUpdates: true)
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
            AboutWindow(id: "about", appName: "Flashcards", developer: "david-swift", version: "0.1.1")
                .icon(.custom(name: "io.github.david_swift.Flashcards"))
                .website(.init(string: "https://github.com/david-swift/Flashcards"))
                .issues(.init(string: "https://github.com/david-swift/Flashcards/issues"))
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
                Window(id: "delete-\(set.id)", open: 0) { window in
                    DeleteView(set: set, window: window) {
                        sets = sets.filter { $0.id != set.id }
                    }
                }
                .defaultSize(width: 450, height: 350)
                .resizable(false)
                .keyboardShortcut("Escape") { $0.close() }
            }
        }
    }

}
