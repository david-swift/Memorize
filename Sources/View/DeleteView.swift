//
//  DeleteView.swift
//  Memorize
//

import Adwaita

struct DeleteView: View {

    var set: FlashcardsSet
    var window: GTUIWindow
    var delete: () -> Void

    var view: Body {
        ScrollView {
            CarouselView(set: .constant(set))
        }
        .vexpand()
        .topToolbar {
            HeaderBar(titleButtons: false) {
                Button(Loc.cancel) {
                    window.close()
                }
            } end: {
                Button(Loc.delete) {
                    delete()
                    window.close()
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
