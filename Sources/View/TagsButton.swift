//
//  TagsButton.swift
//  Memorize
//

import Adwaita

struct TagsButton: SimpleView {

    @Binding var selectedTags: [String]
    @Binding var editTags: Bool
    var tags: [String]
    var starOnly = false

    var view: Body {
        HStack {
            if starOnly {
                if tags.contains(Localized.star.en) || tags.contains(Localized.star.de) {
                    starButton
                }
            } else {
                pickerButton
            }
        }
    }

    var starButton: AnyView {
        tagToggle(tag: Loc.star)
            .flat()
            .circular()
            .tooltip(Loc.star)
    }

    var pickerButton: AnyView {
        Button(
            selectedTags.isEmpty ? "" : "\(selectedTags.count)",
            icon: .custom(name: "io.github.david_swift.Flashcards.tag-outline-symbolic")
        ) {
            editTags = true
        }
        .flat()
        .insensitive(tags.isEmpty)
        .tooltip(Loc.tags)
        .popover(visible: $editTags) {
            popover
        }
    }

    @ViewBuilder var popover: Body {
        Text(Loc.tags)
            .title3()
            .padding(10, .top.add(.horizontal))
        FlowBox(tags, selection: nil) { tag in
            tagToggle(tag: tag)
                .frame(minWidth: 10)
        }
        .padding()
        .frame(maxWidth: 200)
    }

    @ViewBuilder
    func tagToggle(tag: String) -> Body {
        let name = "io.github.david_swift.Flashcards.tag-outline-symbolic"
        let icon: Icon = tag == Localized.star.en || tag == Localized.star.de ? .default(
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
        .flat()
        .modifyContent(ButtonContent.self) { $0.canShrink() }
    }

}
