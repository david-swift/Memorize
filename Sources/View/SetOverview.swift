//
//  SetOverview.swift
//  Memorize
//

import Adwaita

struct SetOverview: View {

    @Binding var set: FlashcardsSet
    @Binding var editMode: Bool
    @Binding var editSearch: Search
    @Binding var searchFocused: Bool
    @Binding var flashcardsView: NavigationStack<FlashcardsView>
    @Binding var importText: String
    @Binding var createSet: Bool
    @State private var export = false
    @State private var deleteState = false
    @State private var copied = Signal()
    var smallWindow: Bool
    var window: GTUIWindow
    var app: GTUIApp
    var delete: () -> Void

    var view: Body {
        ViewStack(element: set) { _ in
            title
                .centerMinSize()
            cards
                .frame(minHeight: 270)
                .valign(.center)
            buttons
                .centerMinSize()
        }
        .topToolbar {
            HeaderBar {
                HStack {
                    Button(icon: .default(icon: .userTrash)) {
                        deleteState = true
                    }
                    .tooltip(Loc.deleteSet)
                    Button(icon: .custom(name: "io.github.david_swift.Flashcards.share-symbolic")) {
                        export = true
                    }
                    .tooltip(Loc.exportSet)
                    .insensitive(set.flashcards.isEmpty)
                }
                .modifyContent(VStack.self) { $0.spacing(5) }
            } end: {
                Button(icon: .default(icon: .documentEdit)) {
                    editMode = true
                }
                .tooltip(Loc.editSet)
            }
            .titleWidget { }
        }
        .dialog(visible: $deleteState, title: Loc.deleteTitle(title: set.name), id: "delete", height: 350) {
            DeleteView(set: set) {
                delete()
            } close: {
                deleteState = false
            }
        }
        .dialog(visible: $export, title: Loc.export(title: set.name), id: "export", width: 400, height: 400) {
            ExportView(copied: $copied, set: set) {
                export = false
            }
        }
        .dialog(visible: $editMode.onSet { _ in createSet = false }, id: "edit", width: 700, height: 550) {
            EditView(
                set: $set,
                editMode: $editMode,
                editSearch: $editSearch,
                searchFocused: $searchFocused,
                importText: $importText,
                createSet: $createSet,
                window: window,
                app: app
            )
        }
        .toast(Loc.copied, signal: copied)
    }

    var title: View {
        VStack {
            HStack {
                Text(set.name)
                    .style("title-1")
                    .padding()
            }
            Text(Loc.flashcards(count: set.flashcards.count))
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
    }

    var buttons: View {
        HStack {
            Button(Loc.studySwitcher, icon: .default(icon: .mediaPlaybackStart)) {
                flashcardsView.push(.study(set: set.id))
            }
            .style("pill")
            Button(Loc.test, icon: .default(icon: .emblemDocuments)) {
                flashcardsView.push(.test(set: set.id))
            }
            .style("pill")
        }
        .halign(.center)
        .modifyContent(VStack.self) { $0.spacing(20) }
        .padding(20)
    }

}
