//
//  ImportView.swift
//  Flashcards
//

import Adwaita
import Foundation
import RegexBuilder

struct ImportView: View {

    @Binding var set: FlashcardsSet
    @State private var flashcardsApp: FlashcardsApp?
    @State private var pasteView = false
    @State private var text = ""
    @State private var switchSides = false
    var window: GTUIWindow

    var view: Body {
        VStack {
            if let flashcardsApp {
                if pasteView {
                    VStack {
                        entry
                        preview
                    }
                    .transition(.slideLeft)
                } else {
                    tutorial(app: flashcardsApp)
                        .centerMinSize()
                }
            } else {
                appView
            }
        }
        .topToolbar {
            HeaderBar(titleButtons: false) {
                Button("Cancel") {
                    window.close()
                }
            } end: {
                Button(pasteView ? "Import" : "Continue") {
                    if pasteView {
                        set.flashcards += previewSet.flashcards
                        window.close()
                    } else {
                        pasteView = true
                    }
                }
                .style("suggested-action")
                .insensitive(flashcardsApp == nil)
            }
        }
    }

    var appView: View {
        List(FlashcardsApp.allCases, selection: nil) { app in
            ActionRow()
                .title(app.name)
                .suffix {
                    ButtonContent()
                        .iconName("go-next-symbolic")
                }
                .activatableWidget {
                    Button()
                        .activate {
                            flashcardsApp = app
                        }
                }
        }
        .style("boxed-list")
        .padding(20)
        .formWidth()
        .transition(.slideLeft)
    }

    var entry: View {
        Form {
            EntryRow("Paste Text", text: $text)
            SwitchRow("Switch Front and Back", isOn: $switchSides)
        }
        .padding(20)
    }

    var preview: View {
        ScrollView {
            CarouselView(set: .constant(previewSet))
        }
        .vexpand()
    }

    var previewSet: FlashcardsSet {
        var previewSet = set
        previewSet.flashcards = []
        let pattern = Regex {
            Capture {
                ZeroOrMore(.anyNonNewline)
            }
            "\t"
            Capture {
                ZeroOrMore(.anyNonNewline)
            }
        }
        for (index, match) in text.matches(of: pattern).enumerated() {
            let (front, back): (Substring, Substring)
            if switchSides {
                (_, back, front) = match.output
            } else {
                (_, front, back) = match.output
            }
            previewSet.flashcards.append(.init(id: "\(index)", front: .init(front), back: .init(back)))
        }
        return previewSet
    }

    var quizletTutorial: View {
        StatusPage(
            "Export Quizlet Set",
            icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
            description: """
            Export a set in <a href="https://quizlet.com">Quizlet</a> under <tt><b> ⋯ > Export</b></tt>.
            Using the default configuration, copy the text.
            """
        ) {
            Button("Show Tutorial") {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/usr/bin/xdg-open")
                process.arguments = [
                    "https://github.com/david-swift/Flashcards/blob/main/data/tutorials/Import.mp4"
                ]
                try? process.run()
            }
            .style("pill")
            .horizontalCenter()
        }
    }

    @ViewBuilder var ankiTutorial: View {
        let ttb = "<tt><b>"
        let ttb2 = "</b></tt>"
        StatusPage(
            "Export Anki Deck",
            icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
            description: """
            Export decks under \(ttb)File > Export\(ttb2).
            Select the export format \(ttb)Cards in Plain Text (.txt)\(ttb2).
            Uncheck \(ttb)Include HTML and media references\(ttb2).
            Copy the content of the text file.
            """
        )
    }

    func tutorial(app: FlashcardsApp) -> View {
        Bin()
            .child {
                switch app {
                case .quizlet:
                    quizletTutorial
                case .anki:
                    ankiTutorial
                }
            }
            .transition(.slideLeft)
    }

}
