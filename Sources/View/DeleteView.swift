//
//  DeleteView.swift
//  Flashcards
//

import Adwaita

struct DeleteView: View {

    var set: FlashcardsSet
    var window: GTUIWindow
    var delete: () -> Void

    var view: Body {
        ScrollView {
            CarouselView(set: set)
        }
        .vexpand()
        .topToolbar {
            HeaderBar(titleButtons: false) {
                Button("Cancel") {
                    window.close()
                }
            } end: {
                Button("Delete") {
                    delete()
                    window.close()
                }
                .style("destructive-action")
            }
            .titleWidget {
                WindowTitle(
                    subtitle: "There is no undo. The flashcards will be lost.",
                    title: "Delete \"\(set.name)\"?"
                )
            }
        }
    }

}
