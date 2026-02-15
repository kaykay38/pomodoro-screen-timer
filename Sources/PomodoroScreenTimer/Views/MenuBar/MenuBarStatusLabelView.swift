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
        let appearance = StatusAppearance(
            phase: model.phase,
            remaining: model.remaining,
            textScale: 0.70,  // 65% of bar height
            iconScale: 1,  // 100% of bar height
            fontWeight: .semibold,
            colorizeText: true,           // phase-colored timer text
            iconName: "timer",
            iconWeight: .bold,
            padding: .init(top: 0, left: 0, bottom: 0, right: 0), // tighter padding
        )
        Image(nsImage: makeStatusImage(appearance))
            .renderingMode(.original)
    }
}
