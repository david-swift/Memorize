//
//  DeleteView.swift
//  Memorize
//

import Adwaita

struct DeleteView: View {

    var set: FlashcardsSet
    var delete: () -> Void
    var close: () -> Void
    // To pass to CarouselView, or fetch the flashcards here
    var dbms: Database

    var view: Body {
        ScrollView {
            CarouselView(set: .constant(set))
        }
        .vexpand()
        .topToolbar {
            HeaderBar(titleButtons: false) {
                Button(Loc.cancel) {
                    close()
                }
            } end: {
                Button(Loc.delete) {
                    close()
                    delete()
                }
                .style("destructive-action")
            }
            .titleWidget {
                WindowTitle(
                    subtitle: Loc.deleteDescription,
                    title: Loc.deleteTitle(title: set.name)
                )
            }
        }
    }

}
