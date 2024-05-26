//
//  KeywordsRow.swift
//  Memorize
//

import Adwaita

struct KeywordsRow: View {

    @Binding var keywords: [String]
    @State private var expanded = false
    @State private var focus = Signal()
    var title = Loc.keywords
    var subtitle = Loc.keywordsDescription
    var element = Loc.keyword

    var view: Body {
        ExpanderRow()
            .title(title)
            .subtitle(subtitle)
            .suffix {
                VStack {
                    Button(icon: .default(icon: .listAdd)) {
                        keywords.append("")
                        expanded = true
                        focus.signal()
                    }
                    .flat()
                    .tooltip(Loc.add(element: element))
                }
                .valign(.center)
            }
            .rows {
                List(.init(keywords.indices), selection: nil) { index in
                    let keyword = keywords[safe: index] ?? ""
                    EntryRow(element, text: .init {
                        keyword
                    } set: { newValue in
                        keywords[safe: index] = newValue
                    })
                    .suffix {
                        VStack {
                            Button(icon: .default(icon: .userTrash)) {
                                keywords = keywords.filter { $0 != keyword }
                            }
                            .flat()
                            .tooltip(Loc.remove(element: element))
                        }
                        .valign(.center)
                    }
                    .entryActivated {
                        keywords.append("")
                        focus.signal()
                    }
                    .focus(index == keywords.count - 1 ? focus : .init())
                }
                .boxedList()
                .padding()
            }
            .enableExpansion(.constant(!keywords.isEmpty))
            .expanded($expanded)
    }

}
