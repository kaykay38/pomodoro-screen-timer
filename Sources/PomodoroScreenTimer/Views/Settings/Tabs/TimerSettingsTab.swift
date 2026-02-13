//
//  TimerSettingsTab.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import SwiftUI

struct TimerSettingsTab: View {
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        VStack(spacing: 16) {
            Text("Durations")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                Grid(
                    alignment: .leading,
                    horizontalSpacing: 12,
                    verticalSpacing: 8
                ) {
                    DurationRow(
                        title: "Focus",
                        stepRange: 1...180,
                        binding: $settings.defaultFocusMinutes,
                        unit: "min"
                    )
                    DurationRow(
                        title: "Short break",
                        stepRange: 1...60,
                        binding: $settings.defaultBreakMinutes,
                        unit: "min"
                    )
                    DurationRow(
                        title: "Long break",
                        stepRange: 1...60,
                        binding: $settings.longBreakMinutes,
                        unit: "min"
                    )
                    DurationRow(
                        title: "Cycles before long break",
                        stepRange: 1...10,
                        binding: $settings.cyclesUntilLongBreak,
                        unit: ""
                    )
                }
            }

            Text("Timer Behavior")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                Toggle(
                    "Auto-start next interval",
                    isOn: $settings.autoCycleEnabled
                )
                Text(
                    "When enabled, the next timer interval starts automatically. When disabled, you'll need to manually start each interval."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }
        }
    }
}
