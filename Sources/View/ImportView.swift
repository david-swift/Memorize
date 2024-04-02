//
//  ImportView.swift
//  Memorize
//

import Adwaita
import Foundation
import RegexBuilder

struct ImportView: View {

    // swiftlint:disable large_tuple
    typealias FlashcardsRegex = Regex<(Substring, Substring, Substring)>
    // swiftlint:enable large_tuple

    @Binding var set: FlashcardsSet
    @Binding var text: String
    @State private var switchSides = false
    @State private var navigationStack = NavigationStack<ImportNavigationDestination>()
    var window: GTUIWindow
    var app: GTUIApp
    var close: () -> Void

    var view: Body {
        VStack {
            NavigationView(
                $navigationStack,
                "Source"
            ) { destination in
                switch destination {
                case let .tutorial(app):
                    tutorial(app: app)
                        .centerMinSize()
                        .topToolbar {
                            toolbar(destination: destination)
                        }
                case let .paste(app):
                    VStack {
                        entry
                        preview(app: app)
                    }
                    .topToolbar {
                        toolbar(destination: destination)
                    }
                }
            } initialView: {
                appView
                    .topToolbar {
                        toolbar(destination: nil)
                    }
                    .valign(.start)
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
                            navigationStack.push(.tutorial(app: app))
                        }
                }
        }
        .style("boxed-list")
        .padding(20)
        .formWidth()
    }

    var entry: View {
        Form {
            EntryRow(Loc.pasteText, text: $text)
                .suffix {
                    Button(icon: .default(icon: .documentOpen)) {
                        app.addWindow("import", parent: window)
                    }
                    .padding(10, .vertical)
                    .style("flat")
                }
            SwitchRow(Loc.switchFrontBack, isOn: $switchSides)
        }
        .padding(20)
    }

    var quizletTutorial: View {
        StatusPage(
            Loc.exportQuizletSet,
            icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
            description: Loc.quizletDescription
        ) {
            Button(Loc.showTutorial) {
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

    var ankiTutorial: View {
        StatusPage(
            Loc.exportAnkiDeck,
            icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
            description: Loc.ankiDescription
        )
    }

    var csvTutorial: View {
        StatusPage(
            Loc.importCSV,
            icon: .default(icon: .emblemDocuments),
            description: Loc.csvDescription
        )
    }

    func preview(app: FlashcardsApp) -> View {
        ScrollView {
            CarouselView(set: .constant(previewSet(app: app)))
        }
        .vexpand()
    }

    func previewSet(app: FlashcardsApp) -> FlashcardsSet {
        var previewSet = set
        previewSet.flashcards = []
        let pattern: FlashcardsRegex
        switch app {
        case .csv:
            pattern = newlineRegex(separator: ",")
        default:
            pattern = newlineRegex(separator: "\t")
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

    func newlineRegex(separator: String) -> FlashcardsRegex {
        .init {
            Capture {
                ZeroOrMore(.anyNonNewline)
            }
            separator
            Capture {
                ZeroOrMore(.anyNonNewline)
            }
        }
    }

    @ViewBuilder
    func tutorial(app: FlashcardsApp) -> View {
        switch app {
        case .quizlet:
            quizletTutorial
        case .anki:
            ankiTutorial
        case .csv:
            csvTutorial
        }
    }

    func toolbar(destination: ImportNavigationDestination?) -> View {
        HeaderBar(titleButtons: false) {
            if destination == nil {
                Button(Loc.cancel) {
                    close()
                }
            }
        } end: {
            let label = {
                switch destination {
                case .paste:
                    Loc._import
                default:
                    Loc._continue
                }
            }()
            Button(label) {
                if case let .paste(app) = destination {
                    set.flashcards += previewSet(app: app).flashcards
                    text = ""
                    close()
                } else {
                    if case let .tutorial(app) = destination {
                        navigationStack.push(.paste(app: app))
                    }
                }
            }
            .style("suggested-action")
            .insensitive(destination == nil)
        }
    }

}
