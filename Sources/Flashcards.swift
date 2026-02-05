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

    init() {
        let userData = AdwaitaApp.userDataDir()
        let oldPath = userData.appendingPathComponent("data.sqlite")
        if FileManager.default.fileExists(atPath: oldPath.path) {
            let newPath = userData.appendingPathComponent("io.github.david_swift.Flashcards.sqlite")
            try? FileManager.default.moveItem(at: oldPath, to: newPath)
        }
    }

}
