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
        .popover(visible: $editTags) {
            popover
        }
    }

    @ViewBuilder var popover: Body {
        ScrollView {
            Text("Tags")
                .style("title-3")
                .padding(10, .top.add(.horizontal))
            FlowBox(tags, selection: nil) { tag in
                tagToggle(tag: tag)
            }
            .padding()
        }
        .frame(minWidth: 200, minHeight: 150)
        .padding(-10)
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
    }

}
