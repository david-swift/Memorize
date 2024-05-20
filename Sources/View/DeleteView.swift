//
//  DeleteView.swift
//  Memorize
//

import Adwaita

struct DeleteView: View {

    var set: FlashcardsSet
    var delete: () -> Void
    var close: () -> Void

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
                .destructive()
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
