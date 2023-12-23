// The Swift Programming Language
// https://docs.swift.org/swift-book

import Adwaita

@main
struct AdwaitaTemplate: App {

    let id = "io.github.AparokshaUI.AdwaitaTemplate"
    var app: GTUIApp!

    var scene: Scene {
        Window(id: "main") { window in
            Text("Hello, world!")
                .padding()
                .topToolbar {
                    ToolbarView(app: app, window: window)
                }
                .onAppear {
                    window.setDefaultSize(width: 450, height: 300)
                }
        }
    }

}
