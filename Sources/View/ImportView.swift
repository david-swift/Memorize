//
//  ImportView.swift
//  Memorize
//

import Adwaita
import Foundation
import RegexBuilder

struct ImportView: View {

    @Binding var set: FlashcardsSet
    @State private var text = ""
    @State private var switchSides = false
    @State private var navigationStack = NavigationStack<ImportNavigationDestination>()
    var window: GTUIWindow

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
                case .paste:
                    VStack {
                        entry
                        preview
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
            SwitchRow(Loc.switchFrontBack, isOn: $switchSides)
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

    @ViewBuilder var ankiTutorial: View {
        StatusPage(
            Loc.exportAnkiDeck,
            icon: .custom(name: "io.github.david_swift.Flashcards.set-symbolic"),
            description: Loc.ankiDescription
        )
    }

    @ViewBuilder
    func tutorial(app: FlashcardsApp) -> View {
        switch app {
        case .quizlet:
            quizletTutorial
        case .anki:
            ankiTutorial
        }
    }

    func toolbar(destination: ImportNavigationDestination?) -> View {
        HeaderBar(titleButtons: false) {
            if destination == nil {
                Button(Loc.cancel) {
                    window.close()
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
                if case .paste = destination {
                    set.flashcards += previewSet.flashcards
                    window.close()
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
