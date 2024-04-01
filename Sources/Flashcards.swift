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
    @State private var importText = ""
    let id = "io.github.david_swift.Flashcards"
    var app: GTUIApp!

    var scene: Scene {
        Window(id: "main") { window in
            ContentView(sets: $sets, importText: $importText, app: app, window: window)
        }
        .title("Memorize")
        .quitShortcut()
        .overlay {
            FileDialog(importer: "import") { url in
                if let contents = try? String(contentsOf: url) {
                    importText = contents
                }
            } onClose: {
            }
        }
    }

}
