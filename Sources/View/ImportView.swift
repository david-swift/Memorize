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
    @State private var text = ""
    @State private var switchSides = false
    @State private var navigationStack = NavigationStack<ImportNavigationDestination>()
    @State private var importer: Signal = .init()
    var window: AdwaitaWindow
    var app: AdwaitaApp
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
        .fileImporter(open: importer) { url in
            if let contents = try? String(contentsOf: url) {
                text = contents
            }
        } onClose: { }
    }

    var appView: AnyView {
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
        .boxedList()
        .padding(20)
        .formWidth()
    }

    var entry: AnyView {
        Form {
            EntryRow(Loc.pasteText, text: $text)
                .suffix {
                    Button(icon: .default(icon: .documentOpen)) {
                        importer.signal()
                    }
                    .padding(10, .vertical)
                    .flat()
                }
            SwitchRow(Loc.switchFrontBack, isOn: $switchSides)
        }
        .padding(20)
    }

    var quizletTutorial: AnyView {
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
            .pill()
            .halign(.center)
        }
    }

    var ankiTutorial: AnyView {
        StatusPage(
            Loc.exportAnkiDeck,
            icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
            description: Loc.ankiDescription
        )
    }

    var csvTutorial: AnyView {
        StatusPage(
            Loc.importCSV,
            icon: .custom(name: "io.github.david_swift.Flashcards.emblem-documents-symbolic"),
            description: Loc.csvDescription
        )
    }

    func preview(app: FlashcardsApp) -> AnyView {
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
    func tutorial(app: FlashcardsApp) -> AnyView {
        switch app {
        case .quizlet:
            quizletTutorial
        case .anki:
            ankiTutorial
        case .csv:
            csvTutorial
        }
    }

    func toolbar(destination: ImportNavigationDestination?) -> AnyView {
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
            .suggested()
            .insensitive(destination == nil)
        }
    }

}
