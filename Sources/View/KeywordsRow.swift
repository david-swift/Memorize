//
//  KeyboardsRow.swift
//  Flashcards
//

import Adwaita

struct KeywordsRow: View {

    @Binding var keywords: [String]
    @State private var expanded = false

    var view: Body {
        ExpanderRow()
            .title("Keywords")
            .suffix {
                VStack {
                    Button(icon: .default(icon: .listAdd)) {
                        keywords.append("")
                        expanded = true
                    }
                    .style("flat")
                }
                .valign(.center)
            }
            .rows {
                List(.init(keywords.indices)) { index in
                    let keyword = keywords[safe: index] ?? ""
                    EntryRow("Keyword", text: .init {
                        keyword
                    } set: { newValue in
                        keywords[safe: index] = newValue
                    })
                    .suffix {
                        VStack {
                            Button(icon: .default(icon: .userTrash)) {
                                keywords = keywords.filter { $0 != keyword }
                            }
                            .style("flat")
                        }
                        .valign(.center)
                    }
                }
                .style("boxed-list")
                .padding()
            }
            .enableExpansion(.constant(!keywords.isEmpty))
            .expanded($expanded)
    }

}
