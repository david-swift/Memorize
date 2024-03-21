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
    }

}
