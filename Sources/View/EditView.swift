//
//  EditView.swift
//  Flashcards
//

import Adwaita

struct EditView: View {

    @Binding var set: FlashcardsSet
    var app: GTUIApp
    var window: GTUIWindow

    var view: Body {
        ScrollView {
            VStack {
                title
                flashcards
                actions
            }
            .formWidth()
        }
        .vexpand()
    }

    var title: View {
        Form {
            EntryRow("Title", text: $set.name)
        }
        .padding(20)
    }

    var flashcards: View {
        ForEach(.init(set.flashcards.indices).reversed()) { index in
            Form {
                front(index: index)
                back(index: index)
            }
            .section("Flashcard \(index + 1)")
            .suffix {
                Button("Delete", icon: .default(icon: .userTrash)) {
                    set.flashcards = set.flashcards.filter { $0.id != set.flashcards[safe: index]?.id }
                }
                .style("flat")
            }
            .padding()
        }
        .padding()
    }

    var actions: View {
        PillButtonSet(
            primary: "Add Flashcard",
            icon: .default(icon: .listAdd),
            secondary: .default(icon: .folderDownload)
        ) {
            set.flashcards.append(.init())
        } secondary: {
            app.addWindow("import-\(set.id)", parent: window)
        }
    }

    func front(index: Int) -> View {
        EntryRow(
            "Front",
            text: .init {
                set.flashcards[safe: index]?.front ?? ""
            } set: { newValue in
                set.flashcards[safe: index]?.front = newValue
            }
        )
    }

    func back(index: Int) -> View {
        EntryRow(
            "Back",
            text: .init {
                set.flashcards[safe: index]?.back ?? ""
            } set: { newValue in
                set.flashcards[safe: index]?.back = newValue
            }
        )
    }

}
