//
//  Flashcards.swift
//  Memorize
//

import Adwaita
import Foundation

@main
struct Flashcards: App {

    @State var dbms = Database()
    let id = "io.github.david_swift.Flashcards"
    var app: GTUIApp!

    var scene: Scene {
        Window(id: "main") { window in
            ContentView(sets: $dbms.sets, app: app, window: window) { newValue in
                if let index = dbms.sets.firstIndex(where: { $0.id == newValue.id }) {
                    _dbms.rawValue.sets[index] = newValue
                }
            }
        }
        .title("Memorize")
        .quitShortcut()
    }

}
