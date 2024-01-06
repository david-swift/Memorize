//
//  PillButtonSet.swift
//  Flashcards
//

import Adwaita

struct PillButtonSet: View {

    var primary: String
    var primaryIcon: Icon
    var secondaryIcon: Icon
    var primaryAction: () -> Void
    var secondaryAction: () -> Void

    var view: Body {
        HStack {
            primaryView
            secondaryView
        }
        .padding(20)
        .modifyContent(Adwaita.Button.self) { $0.padding().style("pill") }
        .horizontalCenter()
    }

    var primaryView: View {
        Button(primary, icon: primaryIcon) {
            primaryAction()
        }
        .style("suggested-action")
    }

    var secondaryView: View {
        Button(icon: secondaryIcon) {
            secondaryAction()
        }
    }

    init(
        primary: String,
        icon primaryIcon: Icon,
        secondary secondaryIcon: Icon,
        primary primaryAction: @escaping () -> Void,
        secondary secondaryAction: @escaping () -> Void
    ) {
        self.primary = primary
        self.primaryIcon = primaryIcon
        self.secondaryIcon = secondaryIcon
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

}
