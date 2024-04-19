//
//  Flashcards.swift
//  Memorize
//

import Adwaita
import Foundation

@main
struct Flashcards: App {

    @State var dbms = Database()
    @State private var importText = ""
    let id = "io.github.david_swift.Flashcards"
    var app: GTUIApp!

    var scene: Scene {
        Window(id: "main") { window in
            ContentView(sets: $dbms.sets, importText: $importText, dbms: dbms, app: app, window: window)
        }
        .title("Memorize")
        .quitShortcut()
        .closeShortcut()
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
