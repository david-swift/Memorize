//
//  TestView.swift
//  Flashcards
//

import Adwaita
import Libadwaita

struct TestView: View {

    @Binding var set: FlashcardsSet

    @State private var allFlashcards = true
    @State private var numberOfQuestions = 1

    var finalNumberOfQuestions: Int {
        (allFlashcards || numberOfQuestions > set.flashcards.count) ? set.flashcards.count : numberOfQuestions
    }

    var view: Body {
        ViewStack(element: set) { set in
            if set.flashcards.isEmpty {
                Text("No flashcards available.")
            } else if set.test.isEmpty {
                configuration
                    .formWidth()
            } else {
                ScrollView {
                    test
                        .formWidth()
                }
                .vexpand()
            }
        }
    }

    var configuration: View {
        FormSection("Configure Test") {
            testConfiguration
            generalSection
        }
        .padding(20)
    }

    var testConfiguration: View {
        Form {
            SwitchRow("All Flashcards", isOn: $allFlashcards)
            SpinRow("Number of Questions", value: $numberOfQuestions, min: 1, max: set.flashcards.count)
                .insensitive(allFlashcards)
        }
        .padding(20, .bottom)
    }

    var generalSection: View {
        Form {
            ComboRow("Answer With", selection: $set.answerSide, values: Flashcard.Side.allCases)
            ActionRow("Testing \(finalNumberOfQuestions) of \(set.flashcards.count) Flashcards")
                .suffix {
                    Button("Start Test") {
                        startTest()
                    }
                    .style("suggested-action")
                    .verticalCenter()
                }
        }
    }

    @ViewBuilder var test: Body {
        FormSection("Solve Test") {
            Container(set.test) { id in
                if let index = set.studyFlashcards.firstIndex(where: { $0.id == id }) {
                    FlashcardTestSection(
                        flashcard: .init {
                            set.studyFlashcards[safe: index] ?? .init()
                        } set: { newValue in
                            set.studyFlashcards[safe: index] = newValue
                        }
                    )
                }
            } container: {
                Box(horizontal: false)
            }
        }
        .padding(20)
        score
        testButtons
    }

    var score: View {
        Form {
            if let score = set.score {
                if score == finalNumberOfQuestions {
                    scoreRow
                        .subtitle("Full Score!")
                } else {
                    scoreRow
                        .subtitle("\(score) Point\(score == 1 ? "" : "s")")
                }
            } else {
                scoreRow
                    .subtitle("-")
            }
            ActionRow("Maximum Score")
                .subtitle("\(finalNumberOfQuestions) Point\(finalNumberOfQuestions == 1 ? "" : "s")")
        }
        .modifyContent(Adwaita.ActionRow.self) { $0.style("property") }
        .section("Score")
        .description(set.score == nil ? "Scroll down to check your answers." : "")
        .padding(20, .horizontal.add(.bottom))
    }

    var scoreRow: Adwaita.ActionRow {
        .init("Your Score")
    }

    var testButtons: View {
        PillButtonSet(
            primary: "Check",
            icon: .default(icon: .emblemOk),
            secondary: .default(icon: .goNext)
        ) {
            set.check()
        } secondary: {
            set.done()
        }
    }

    func startTest() {
        var randomElements: Set<String> = []
        while randomElements.count < finalNumberOfQuestions {
            if let random = set.flashcards[safe: Int.random(in: 0..<set.flashcards.count)] {
                randomElements.insert(random.id)
            }
        }
        set.test = .init(randomElements)
    }

}
