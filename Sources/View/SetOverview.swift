//
//  SetOverview.swift
//  Memorize
//

import Adwaita

struct SetOverview: View {

    @Binding var set: FlashcardsSet
    @Binding var editMode: Bool
    var app: GTUIApp
    var window: GTUIWindow

    var view: Body {
        ViewStack(element: set) { _ in
            if editMode {
                VStack {
                    EditView(set: $set, editMode: $editMode, app: app, window: window)
                }
            } else {
                ScrollView {
                    title
                    cards
                }
            }
        }
    }

    var title: View {
        HStack {
            Text(set.name)
                .style("title-1")
                .padding()
            Button(icon: .default(icon: .documentEdit)) {
                editMode = true
            }
            .style("circular")
            .tooltip(Loc.editSet)
            .padding()
        }
        .halign(.center)
    }

    var cards: View {
        ViewStack(element: set) { _ in
            VStack {
                CarouselView(set: $set)
            }
            .transition(.crossfade)
        }
        .centerMinSize()
    }

}
