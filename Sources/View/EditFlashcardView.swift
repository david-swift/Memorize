//
//  EditFlashcardView.swift
//  Flashcards
//

import Adwaita

struct EditFlashcardView: View {

    @Binding var flashcard: Flashcard
    @State private var editTags = false
    var index: Int
    var tags: [String]
    var delete: () -> Void

    var view: Body {
        FormSection("Flashcard \(index + 1)") {
            Form {
                EntryRow("Front", text: $flashcard.front)
                EntryRow("Back", text: $flashcard.back)
            }
        }
        .suffix {
            HStack {
                TagsButton(selectedTags: $flashcard.tags.nonOptional, editTags: $editTags, tags: tags)
                Button(icon: .default(icon: .userTrash)) {
                    delete()
                }
                .style("flat")
            }
        }
        .padding()
    }

}
