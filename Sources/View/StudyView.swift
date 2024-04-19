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
    // Needs to access almost all of the set data
    // Modifies the game data of the flashcards and set
    var dbms: Database

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
                    } else {
                        entryView(flashcard: flashcard)
                            .valign(.center)
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
                        .style("osd")
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
                .style("suggested-action")
                .verticalCenter()
            }
            .insensitive(set.studyFlashcards.isEmpty)
        }
        .padding(20)
        .formWidth()
    }

    var sideSwitchRow: View {
        SwitchRow(Loc.answerWithBack, isOn: $set.answerWithBack)
    }

    var entryButtons: View {
        PillButtonSet(
            primary: Loc.check,
            icon: .default(icon: .emblemOk),
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

    func solutionView(flashcard: Flashcard) -> View {
        VStack {
            if input == flashcard.back {
                solutionRow(answer: input)
            } else {
                solutionRow(answer: input)
            }
            solutionButtons(flashcard: flashcard)
        }
        .formWidth()
        .transition(.slideLeft)
    }

    func solutionButtons(flashcard: Flashcard) -> View {
        PillButtonSet(
            primary: Loc._continue,
            icon: .default(icon: .goNext),
            secondary: flashcard.back == input ? Loc.makeIncorrect : Loc.makeCorrect,
            icon: flashcard.back == input
            ? .custom(name: "io.github.david_swift.Flashcards.mistake-symbolic") : .default(icon: .emblemOk),
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

    func entryView(flashcard: Flashcard) -> View {
        VStack {
            Form {
                ActionRow(flashcard.front)
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
        .transition(.slideLeft)
    }

    func continueStudying() {
        solution = false
        if let id = set.filteredStudyCards.randomElement() {
            randomID = id
        }
        Task {
            input = ""
            focusDefaults.signal()
        }
    }

    func check() {
        solution = true
        focusDefaults.signal()
    }

    func solutionRow(answer: String) -> View {
        let solution = flashcard?.back ?? ""
        let correct = answer == solution
        return Form {
            ActionRow(Loc.solution)
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
            ActionRow(correct ? Loc.correct : Loc.yourAnswer)
                .subtitle(answer)
                .style("property")
                .style(correct ? "success" : "error")
        }
        .padding(20)
    }

    func getFlashcard(id: String) -> Flashcard? {
        self.set.testFlashcards.first { $0.id == id }
    }

}
