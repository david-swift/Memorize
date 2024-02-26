//
//  TagsButton.swift
//  Flashcards
//

import Adwaita

struct TagsButton: View {

    @Binding var selectedTags: [String]
    @Binding var editTags: Bool
    var tags: [String]
    var starOnly = false

    var view: Body {
        HStack {
            if starOnly {
                if tags.contains("Star") {
                    starButton
                }
            } else {
                pickerButton
            }
        }
    }

    var starButton: View {
        tagToggle(tag: "Star")
            .style("flat")
            .style("circular")
            .tooltip("Star")
    }

    var pickerButton: View {
        Button(
            selectedTags.isEmpty ? "" : "\(selectedTags.count)",
            icon: .custom(name: "io.github.david_swift.Flashcards.tag-outline-symbolic")
        ) {
            editTags = true
        }
        .style("flat")
        .insensitive(tags.isEmpty)
        .tooltip("Tags")
        .popover(visible: $editTags) {
            popover
        }
    }

    @ViewBuilder var popover: Body {
        Text("Tags")
            .style("title-3")
            .padding(10, .top.add(.horizontal))
        FlowBox(tags, selection: nil) { tag in
            tagToggle(tag: tag)
                .frame(minWidth: 10)
        }
        .padding()
        .frame(maxWidth: 200)
    }

    @ViewBuilder
    func tagToggle(tag: String) -> View {
        let name = "io.github.david_swift.Flashcards.tag-outline-symbolic"
        let icon: Icon = tag == "Star" ? .default(
            icon: selectedTags.contains(tag) ? .starred : .nonStarred
        ) : .custom(name: name)
        ToggleButton(
            starOnly ? "" : tag,
            icon: icon,
            isOn: .init {
                selectedTags.contains(tag)
            } set: { newValue in
                if newValue && !selectedTags.contains(tag) {
                    selectedTags.append(tag)
                } else if !newValue {
                    selectedTags = selectedTags.filter { $0 != tag }
                }
            }
        )
        .style("flat")
        .modifyContent(ButtonContent.self) { $0.canShrink() }
    }

}
