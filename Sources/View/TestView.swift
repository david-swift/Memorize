//
//  TestView.swift
//  Flashcards
//

import Adwaita

struct TestView: View {

    @Binding var set: FlashcardsSet
    @State private var roundIndex = 0

    var view: Body {
        ViewStack(element: set) { set in
            if set.flashcards.isEmpty {
                Text("No flashcards available.")
            } else if set.test.isEmpty {
                configuration
                    .valign(.center)
            } else {
                ViewStack(id: roundIndex) { _ in
                    ScrollView {
                        test
                            .formWidth()
                    }
                    .vexpand()
                }
            }
        }
    }

    @ViewBuilder var configuration: View {
        TagFilterForm(
            allFlashcards: $set.testAllFlashcards.nonOptional,
            selectedTags: $set.testTags.nonOptional,
            tags: set.tags.nonOptional
        )
        Form {
            SpinRow(
                "Number of Questions",
                value: $set.numberOfQuestions.nonOptional,
                min: 1,
                max: set.testFlashcards.count
            )
        }
        .padding(20, .horizontal.add(.top))
        .formWidth()
        generalSection
            .padding(20)
            .formWidth()
    }

    var generalSection: View {
        Form {
            SwitchRow("Answer With Back", isOn: $set.answerWithBack)
            ActionRow("Testing \(set.numberOfQuestions.nonOptional) of \(set.flashcards.count) Flashcards")
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
            ForEach(set.test) { id in
                if let index = set.testFlashcards.firstIndex(where: { $0.id == id }) {
                    FlashcardTestSection(
                        flashcard: .init {
                            set.testFlashcards[safe: index] ?? .init()
                        } set: { newValue in
                            set.testFlashcards[safe: index] = newValue
                        }
                    )
                }
            }
        }
        .padding(20)
        score
        testButtons
    }

    var score: View {
        Form {
            if let score = set.score {
                if score == set.numberOfQuestions {
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
                .subtitle("\(set.numberOfQuestions ?? 1) Point\(set.numberOfQuestions.nonOptional == 1 ? "" : "s")")
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
        roundIndex += 1
        var randomElements: Set<String> = []
        while randomElements.count < set.numberOfQuestions.nonOptional {
            if let random = set.testFlashcards.randomElement() {
                randomElements.insert(random.id)
            }
        }
        set.test = .init(randomElements)
    }

}
