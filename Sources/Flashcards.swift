//
//  Flashcards.swift
//  Memorize
//

import Adwaita
import Foundation

@main
struct Flashcards: App {

    @State("sets", forceUpdates: true)
    private var sets: [FlashcardsSet] = []
    let app = AdwaitaApp(id: "io.github.david_swift.Flashcards")

    var scene: Scene {
        Window(id: "main") { window in
            ContentView(sets: $sets, app: app, window: window)
        }
        .title("Memorize")
        .quitShortcut()
        .closeShortcut()
    }

}
