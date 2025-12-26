//
//  StudyView.swift
//  Memorize
//

import Adwaita

struct StudyView: View {

    @Binding var set: FlashcardsSet
    @State private var input = ""
    @State private var randomID = ""
    @State private var solution = false
    @State private var initialDifficulty = 1
    @State private var focusDefaults = Signal()

    var flashcard: Flashcard? {
        getFlashcard(id: randomID)
    }

    var view: Body {
        VStack {
            if set.flashcards.isEmpty {
                Text(Loc.noFlashcards)
            } else if set.filteredStudyCards.isEmpty {
                StatusPage()
                    .title(Loc.study(title: set.name))
                    .description(Loc.studyDescription)
                    .iconName(Icon.default(icon: .mediaPlaylistRepeat).string)
                    .child {
                        startConfiguration
                    }
            } else {
                if let flashcard {
                    if solution {
                        solutionView(flashcard: flashcard)
                            .valign(.center)
                            .transition(.slideLeft)
                    } else {
                        entryView(flashcard: flashcard)
                            .valign(.center)
                            .transition(.slideLeft)
                    }
                } else {
                    pauseView
                }
            }
        }
        .vexpand()
        .valign(.center)
        .overlay {
            VStack {
                if !set.filteredStudyCards.isEmpty {
                    ProgressBar(value: .init(set.completedCardsCount), total: .init(set.studyFlashcards.count))
                        .osd()
                }
            }
            .insensitive()
        }
    }

    @ViewBuilder var startConfiguration: Body {
        TagFilterForm(
            allFlashcards: $set.studyAllFlashcards.nonOptional,
            selectedTags: $set.studyTags.nonOptional,
            tags: set.tags.nonOptional
        )
        Form {
            sideSwitchRow
            SpinRow(Loc.initialDifficulty, value: $initialDifficulty, min: 1, max: 20)
                .subtitle(Loc.initialDifficultyDescription)
            ActionRow(Loc.studySummary(
                count: set.studyFlashcards.count,
                total: set.flashcards.count
            ))
            .suffix {
                Button(Loc.startStudyMode) {
                    set.setDifficulty(initialDifficulty)
                    continueStudying()
                }
                .suggested()
                .valign(.center)
            }
            .insensitive(set.studyFlashcards.isEmpty)
        }
        .padding(20)
        .formWidth()
    }

    var sideSwitchRow: AnyView {
        SwitchRow(Loc.answerWithBack, isOn: $set.answerWithBack)
    }

    var entryButtons: AnyView {
        PillButtonSet(
            primary: Loc.check,
            icon: .custom(name: "io.github.david_swift.Flashcards.emblem-ok-symbolic"),
            secondary: Loc.studySettings,
            icon: .custom(name: "io.github.david_swift.Flashcards.settings-symbolic")
        ) {
            check()
        } secondary: {
            randomID = ""
        }
    }

    @ViewBuilder var pauseView: Body {
        StatusPage()
            .title(Loc.activeStudySession)
            .description(Loc.activeStudySessionDescription)
            .child {
                Form {
                    sideSwitchRow
                }
                .padding(20)
                .formWidth()
                PillButtonSet(
                    primary: Loc.continueStudying,
                    icon: .default(icon: .mediaPlaybackStart),
                    secondary: Loc.terminateStudyMode,
                    icon: .default(icon: .mediaSkipBackward)
                ) {
                    continueStudying()
                } secondary: {
                    set.resetStudyProgress()
                }
            }
    }

    func solutionView(flashcard: Flashcard) -> AnyView {
        VStack {
            if input == flashcard.back {
                solutionRow(answer: input)
            } else {
                solutionRow(answer: input)
            }
            solutionButtons(flashcard: flashcard)
        }
        .formWidth()
    }

    func solutionButtons(flashcard: Flashcard) -> AnyView {
        PillButtonSet(
            primary: Loc._continue,
            icon: .default(icon: .goNext),
            secondary: flashcard.back == input ? Loc.makeIncorrect : Loc.makeCorrect,
            icon: .custom(
                name: flashcard.back == input ?
                "io.github.david_swift.Flashcards.mistake-symbolic" :
                "io.github.david_swift.Flashcards.emblem-ok-symbolic"
            ),
            focus: focusDefaults
        ) {
            let index = set.flashcards.firstIndex { $0.id == getFlashcard(id: randomID)?.id }
            if input == flashcard.back {
                set.flashcards[safe: index]?.gameData.difficulty -= 1
            } else {
                set.flashcards[safe: index]?.gameData.difficulty += 1
            }
            continueStudying()
        } secondary: {
            input = input == flashcard.back ? "" : flashcard.back
        }
    }

    func entryView(flashcard: Flashcard) -> AnyView {
        VStack {
            Form {
                ActionRow(flashcard.front)
                    .useMarkup(false)
                EntryRow(Loc.answer, text: $input)
                    .entryActivated {
                        check()
                    }
                    .insensitive(solution)
                    .focus(focusDefaults)
            }
            .padding(20)
            entryButtons
        }
        .formWidth()
    }

    func continueStudying() {
        solution = false
        if let id = set.filteredStudyCards.randomElement() {
            randomID = id
        }
        Task {
            Idle {
                input = ""
                focusDefaults.signal()
            }
        }
    }

    func check() {
        solution = true
        focusDefaults.signal()
    }

    func solutionRow(answer: String) -> AnyView {
        let solution = flashcard?.back ?? ""
        let correct = answer == solution
        return Form {
            ActionRow(Loc.solution)
                .useMarkup(false)
                .subtitle(solution)
                .suffix {
                    TagsButton(
                        selectedTags: .init {
                            (flashcard?.tags).nonOptional
                        } set: { newValue in
                            set.flashcards[safe: set.flashcards.firstIndex { $0.id == flashcard?.id }]?.tags = newValue
                        },
                        editTags: .constant(false),
                        tags: set.tags.nonOptional,
                        starOnly: true
                    )
                    .padding()
                }
                .property()
            ActionRow(correct ? Loc.correct : Loc.yourAnswer)
                .useMarkup(false)
                .subtitle(answer)
                .property()
                .style(correct ? "success" : "error")
        }
        .padding(20)
    }

    func getFlashcard(id: String) -> Flashcard? {
        self.set.testFlashcards.first { $0.id == id }
    }

}
