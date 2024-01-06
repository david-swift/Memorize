//
//  ImportView.swift
//  Flashcards
//

import Adwaita
import Foundation
import RegexBuilder

struct ImportView: View {

    @Binding var set: FlashcardsSet
    @State private var pasteView = false
    @State private var text = ""
    @State private var switchSides = false
    var window: GTUIWindow

    var view: Body {
        VStack {
            if pasteView {
                VStack {
                    entry
                    preview
                }
                .transition(.slideLeft)
            } else {
                tutorial
                    .centerMinSize()
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
            }
        }
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
            CarouselView(set: previewSet)
        }
        .vexpand()
    }

    var tutorial: View {
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

}
