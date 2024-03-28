//
//  Flashcards.swift
//  Memorize
//

import Adwaita
import Foundation

@main
struct Flashcards: App {

    @State private var database = Database()
    let id = "io.github.david_swift.Flashcards"
    var app: GTUIApp!

    var scene: Scene {
        Window(id: "main") { window in
            ContentView(sets: $database.sets, app: app, window: window) { newValue in
                if let index = database.sets.firstIndex(where: { $0.id == newValue.id }) {
                    _database.rawValue.sets[index] = newValue
                }
            }
        }
        .title("Memorize")
        .quitShortcut()
    }

}
