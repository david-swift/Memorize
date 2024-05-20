//
//  PillButtonSet.swift
//  Memorize
//

import Adwaita

struct PillButtonSet: View {

    var primary: String
    var primaryIcon: Icon
    var secondary: String
    var secondaryIcon: Icon
    var focus: Signal?
    var primaryAction: () -> Void
    var secondaryAction: () -> Void

    var view: Body {
        HStack {
            primaryView
            secondaryView
        }
        .padding(20)
        .modifyContent(Adwaita.Button.self) { $0.padding().pill() }
        .horizontalCenter()
    }

    var primaryView: View {
        Button(primary, icon: primaryIcon) {
            primaryAction()
        }
        .suggested()
        .focus(focus ?? .init())
    }

    var secondaryView: View {
        Button(icon: secondaryIcon) {
            secondaryAction()
        }
        .tooltip(secondary)
    }

    init(
        primary: String,
        icon primaryIcon: Icon,
        secondary: String,
        icon secondaryIcon: Icon,
        focus: Signal? = nil,
        primary primaryAction: @escaping () -> Void,
        secondary secondaryAction: @escaping () -> Void
    ) {
        self.primary = primary
        self.primaryIcon = primaryIcon
        self.secondary = secondary
        self.secondaryIcon = secondaryIcon
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.focus = focus
    }

}
