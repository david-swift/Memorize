//
//  StudyView.swift
//  Flashcards
//

import Adwaita

struct StudyView: View {

    @Binding var set: FlashcardsSet
    @State private var input = ""
    @State private var randomID = ""
    @State private var solution = false
    @State private var initialDifficulty = 1

    var flashcard: Flashcard? {
        getFlashcard(id: randomID)
    }

    var view: Body {
        VStack {
            if set.filteredStudyCards.isEmpty {
                startConfiguration
                startButton
            } else if let flashcard {
                if solution {
                    solutionView(flashcard: flashcard)
                } else {
                    entryView(flashcard: flashcard)
                }
            } else {
                pauseView
            }
        }
        .vexpand()
        .valign(.center)
        .overlay {
            VStack {
                if !set.filteredStudyCards.isEmpty {
                    ProgressBar(value: .init(set.completedCardsCount), total: .init(set.flashcards.count))
                        .style("osd")
                }
            }
            .insensitive()
        }
    }

    var startConfiguration: View {
        Form {
            sideSwitchRow
            SpinRow("Initial Difficulty", value: $initialDifficulty, min: 1, max: 20)
                .subtitle("Set the minimum number of repetitions per flashcard.")
        }
        .padding(20)
        .formWidth()
    }

    var startButton: View {
        Button("Start Study Mode") {
            set.setDifficulty(initialDifficulty)
            continueStudying()
        }
        .style("pill")
        .style("suggested-action")
        .padding(20)
        .horizontalCenter()
    }

    var sideSwitchRow: View {
        ComboRow("Answer With", selection: $set.answerSide, values: Flashcard.Side.allCases)
    }

    var entryButtons: View {
        PillButtonSet(
            primary: "Check",
            icon: .default(icon: .emblemOk),
            secondary: .custom(name: "io.github.david_swift.Flashcards.settings-symbolic")
        ) {
            check()
        } secondary: {
            randomID = ""
        }
    }

    @ViewBuilder var pauseView: Body {
        Form {
            sideSwitchRow
        }
        .padding(20)
        .formWidth()
        PillButtonSet(
            primary: "Continue Studying",
            icon: .default(icon: .mediaPlaybackStart),
            secondary: .default(icon: .mediaSkipBackward)
        ) {
            continueStudying()
        } secondary: {
            set.resetStudyProgress()
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
            primary: "Continue",
            icon: .default(icon: .goNext),
            secondary: flashcard.back == input
            ? .custom(name: "io.github.david_swift.Flashcards.mistake-symbolic") : .default(icon: .emblemOk)
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
                EntryRow("Answer", text: $input)
                    .onSubmit {
                        check()
                    }
                    .insensitive(solution)
            }
            .padding(20)
            entryButtons
        }
        .formWidth()
        .transition(.slideLeft)
    }

    func continueStudying() {
        if let id = set.filteredStudyCards.randomElement() {
            randomID = id
        }
        solution = false
        Task {
            input = ""
        }
    }

    func check() {
        solution = true
    }

    func solutionRow(answer: String) -> View {
        let solution = flashcard?.back ?? ""
        let correct = answer == solution
        return Form {
            ActionRow("Solution")
                .subtitle(solution)

            ActionRow(correct ? "Correct!" : "Your Answer")
                .subtitle(answer)
                .style("property")
                .style(correct ? "success" : "error")
        }
        .padding(20)
    }

    func getFlashcard(id: String) -> Flashcard? {
        self.set.studyFlashcards.first { $0.id == id }
    }

}
