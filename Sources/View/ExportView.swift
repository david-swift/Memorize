//
//  ExportView.swift
//  Flashcards
//

import Adwaita

struct ExportView: View {

    @State private var termDefinitionSeparator: TermDefinitionSeparator = .tab
    @State private var rowSeparator: RowSeparator = .newLine
    @State private var switchSides = false
    var set: FlashcardsSet
    var window: GTUIWindow

    var view: Body {
        ScrollView {
            Form {
                ComboRow(
                    "Between Term and Definition",
                    selection: $termDefinitionSeparator,
                    values: [TermDefinitionSeparator.tab, .comma]
                )
                ComboRow(
                    "Between Rows",
                    selection: $rowSeparator,
                    values: [RowSeparator.newLine, .semicolon]
                )
                SwitchRow(
                    "Switch Front and Back",
                    isOn: $switchSides
                )
            }
            .padding(20)
            Form {
                Text(text)
                    .wrap()
                    .selectable()
                    .halign(.start)
                    .padding()
            }
            .padding(20, .bottom.add(.horizontal))
        }
        .topToolbar {
            HeaderBar(titleButtons: false) {
                Button("Cancel") {
                    window.close()
                }
            } end: {
                Button("Copy") {
                    State<Any>.copy(text)
                    window.close()
                }
                .style("suggested-action")
            }
        }
    }

    var text: String {
        var text = ""
        let flashcards = set.flashcards.map { flashcard in
            if switchSides {
                var flashcard = flashcard
                (flashcard.front, flashcard.back) = (flashcard.back, flashcard.front)
                return flashcard
            }
            return flashcard
        }
        for flashcard in flashcards {
            text += flashcard.front + termDefinitionSeparator.syntax + flashcard.back + rowSeparator.syntax
        }
        text.removeLast(rowSeparator.syntax.count)
        return text
    }

    enum TermDefinitionSeparator: String, CustomStringConvertible, Identifiable {

        case tab
        case comma

        var id: Self { self }
        var description: String { rawValue.capitalized }
        var syntax: String {
            switch self {
            case .tab:
                "\t"
            case .comma:
                ","
            }
        }

    }

    enum RowSeparator: String, CustomStringConvertible, Identifiable {

        case newLine = "new line"
        case semicolon

        var id: Self { self }
        var description: String { rawValue.capitalized }
        var syntax: String {
            switch self {
            case .newLine:
                "\n"
            case .semicolon:
                ";"
            }
        }

    }

}
