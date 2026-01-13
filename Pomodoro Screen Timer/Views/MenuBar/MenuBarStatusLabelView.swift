//
//  MenuBarStatusLabelView.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/20/25.
//

import SwiftUI

struct MenuBarStatusLabel: View {
    @EnvironmentObject var model: TimerModel

    var body: some View {
        #if os(macOS)
        let appearance = StatusAppearance(
            phase: model.phase,
            remaining: model.remaining,
            fontSize: 15,                 // try 15–16 for “bigger”
            fontWeight: .semibold,
            colorizeText: true,           // phase-colored timer text
            iconName: "timer",
            iconWeight: .bold,
            padding: .init(top: 1, left: 0, bottom: 1, right: 0), // tighter padding
            fixedTemplate: "10:00"     // keeps width static
        )
        Image(nsImage: makeStatusImage(appearance))
            .renderingMode(.original)
        #else
        EmptyView()
        #endif
    }
}
