//
//  TagFilterForm.swift
//  Flashcards
//

import Adwaita

struct TagFilterForm: View {

    @Binding var allFlashcards: Bool
    @Binding var selectedTags: [String]
    @State private var editTags = false
    var tags: [String]

    var view: Body {
        Form {
            SwitchRow("All Flashcards", isOn: $allFlashcards)
            ActionRow()
                .title("Flashcards With Tags")
                .activatableWidget {
                    Button()
                        .activate {
                            editTags = true
                        }
                }
                .suffix {
                    TagsButton(
                        selectedTags: $selectedTags,
                        editTags: $editTags,
                        tags: tags
                    )
                    .padding()
                }
                .insensitive(allFlashcards)
        }
        .padding(20, .horizontal.add(.top))
        .formWidth()
    }

}
