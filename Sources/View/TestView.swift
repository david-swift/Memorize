//
//  TestView.swift
//  Memorize
//

import Adwaita

struct TestView: View {

    @Binding var set: FlashcardsSet
    @State private var roundIndex = 0
    @State private var focusedFlashcard: String?
    @State private var focusFlashcard: Signal = .init()
    // Needs to access almost all of the set data
    // Modifies the game data of the flashcards and set
    var dbms: Database

    var view: Body {
        ViewStack(element: set) { set in
            if set.flashcards.isEmpty {
                Text(Loc.noFlashcards)
            } else if set.test.isEmpty {
                StatusPage()
                    .title(Loc.generateExam)
                    .description(Loc.generateExamDescription(title: set.name))
                    .iconName(Icon.default(icon: .toolsCheckSpelling).string)
                    .child {
                        configuration
                    }
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
        generalSection
            .padding(20)
            .formWidth()
    }

    var generalSection: View {
        Form {
            SwitchRow(Loc.answerWithBack, isOn: $set.answerWithBack)
            SpinRow(
                Loc.numberOfQuestions,
                value: $set.numberOfQuestions.nonOptional,
                min: 1,
                max: set.testFlashcards.count
            )
            ActionRow(Loc.testDescription(
                count: set.numberOfQuestions.nonOptional,
                total: set.flashcards.count
            ))
            .suffix {
                Button(Loc.createTest) {
                    startTest()
                }
                .suggested()
                .verticalCenter()
            }
            .insensitive(set.testFlashcards.isEmpty)
        }
    }

    @ViewBuilder var test: Body {
        FormSection(Loc.solveTest) {
            ForEach(set.test) { id in
                if let index = set.testFlashcards.firstIndex(where: { $0.id == id }) {
                    FlashcardTestSection(
                        flashcard: .init {
                            set.testFlashcards[safe: index] ?? .init()
                        } set: { newValue in
                            set.testFlashcards[safe: index] = newValue
                        },
                        focusedFlashcard: focusedFlashcard,
                        focusFlashcard: focusFlashcard
                    ) {
                        if let testIndex = set.test.firstIndex(
                            where: { $0.id == set.testFlashcards[safe: index]?.id }
                        ) {
                            focusedFlashcard = set.test[safe: testIndex + 1]
                            focusFlashcard.signal()
                        }
                    }
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
                        .subtitle(Loc.fullScore)
                } else {
                    scoreRow
                        .subtitle(Loc.score(score: score))
                }
            } else {
                scoreRow
                    .subtitle(Loc.noScoreData)
            }
            ActionRow(Loc.maxScore)
                .subtitle(Loc.score(score: set.numberOfQuestions ?? 1))
        }
        .modifyContent(Adwaita.ActionRow.self) { $0.property() }
        .section(Loc.scoreLabel)
        .description(set.score == nil ? Loc.scoreInstructions : "")
        .padding(20, .horizontal.add(.bottom))
    }

    var scoreRow: Adwaita.ActionRow {
        .init(Loc.scoreRowLabel)
    }

    var testButtons: View {
        PillButtonSet(
            primary: Loc.check,
            icon: .default(icon: .emblemOk),
            secondary: Loc.finishTest,
            icon: .default(icon: .goNext)
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
