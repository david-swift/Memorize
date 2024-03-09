//
//  Flashcards.swift
//  Memorize
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
        .title("Memorize")
        .quitShortcut()
        .overlay {
            AboutWindow(id: "about", appName: "Memorize", developer: "david-swift", version: "0.1.4")
                .icon(.custom(name: "io.github.david_swift.Flashcards"))
                .website(.init(string: "https://github.com/david-swift/Memorize"))
                .issues(.init(string: "https://github.com/david-swift/Memorize/issues"))
            for (index, set) in sets.enumerated() {
                // Import flashcards and add to a set.
                Window(id: "import-\(set.id)", open: 0) { window in
                    ImportView(
                        set: .init { set } set: { sets[safe: index] = $0 },
                        window: window
                    )
                }
                .defaultSize(width: 500, height: 500)
                .keyboardShortcut("Escape") { $0.close() }

                // Export a set.
                Window(id: "export-\(set.id)", open: 0) { window in
                    ExportView(set: set, window: window)
                }
                .title(Loc.export(title: set.name))
                .defaultSize(width: 500, height: 500)
                .keyboardShortcut("Escape") { $0.close() }

                // Delete a set.
                Window(id: "delete-\(set.id)", open: 0) { window in
                    DeleteView(set: set, window: window) { sets = sets.filter { $0.id != set.id } }
                }
                .defaultSize(width: 450, height: 350)
                .resizable(false)
                .keyboardShortcut("Escape") { $0.close() }
            }
        }
    }

}
