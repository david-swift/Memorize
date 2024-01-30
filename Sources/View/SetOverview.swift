//
//  SetOverview.swift
//  Flashcards
//

import Adwaita

struct SetOverview: View {

    @State private var editMode = false
    @Binding var set: FlashcardsSet
    var app: GTUIApp
    var window: GTUIWindow

    var view: Body {
        ViewStack(element: set) { _ in
            if editMode {
                VStack {
                    EditView(set: $set, app: app, window: window)
                }
                .transition(.slideUp)
            } else {
                ScrollView {
                    title
                    cards
                }
                .transition(.slideDown)
            }
        }
        .bottomToolbar(visible: editMode) {
            HeaderBar(titleButtons: false) {
                ViewStack(element: set) { _ in
                    Button("Delete Set", icon: .default(icon: .userTrash)) {
                        showDeleteDialog()
                    }
                }
            } end: {
                Button("Done") {
                    editMode = false
                }
                .style("suggested-action")
            }
            .headerBarTitle { }
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
            .padding()
        }
        .halign(.center)
    }

    var cards: View {
        ViewStack(element: set) { set in
            VStack {
                CarouselView(set: set)
            }
            .transition(.crossfade)
        }
        .centerMinSize()
    }

    func showDeleteDialog() {
        app.addWindow("delete-\(set.id)", parent: window)
    }

}
