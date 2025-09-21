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
            iconName: "timer.circle.fill",
            iconWeight: .bold,
            padding: .init(top: 1, left: 1, bottom: 1, right: 1), // tighter padding
            spacing: 2,
            fixedTemplate: "L 100:00"     // keeps width static
        )
        Image(nsImage: makeStatusImage(appearance))
            .renderingMode(.original)
        #else
        EmptyView()
        #endif
    }
}
