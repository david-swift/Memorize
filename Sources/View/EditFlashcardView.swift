//
//  EditFlashcardView.swift
//  Memorize
//

import Adwaita

struct EditFlashcardView: View {

    @Binding var flashcard: Flashcard
    @State private var editTags = false
    @State private var focusBack = Signal()
    var index: Int
    var tags: [String]
    var focusedFront: String?
    var focusFront: Signal
    var focusNext: () -> Void
    var delete: () -> Void
    // Unless you fetch the flashcard further up in the view tree
    // This view needs to be able to set the flashcard's front and back
    var dbms: Database

    var view: Body {
        FormSection(Loc.flashcard(index: index + 1)) {
            Form {
                EntryRow(Loc.front, text: $flashcard.front)
                    .entryActivated {
                        focusBack.signal()
                    }
                    .focus(focusedFront == flashcard.id ? focusFront : .init())
                EntryRow(Loc.back, text: $flashcard.back)
                    .entryActivated {
                        focusNext()
                    }
                    .focus(focusBack)
            }
        }
        .suffix {
            HStack {
                TagsButton(selectedTags: $flashcard.tags.nonOptional, editTags: $editTags, tags: tags)
                Button(icon: .default(icon: .userTrash)) {
                    delete()
                }
                .flat()
                .tooltip(Loc.deleteFlashcard)
            }
        }
        .padding()
    }

}
