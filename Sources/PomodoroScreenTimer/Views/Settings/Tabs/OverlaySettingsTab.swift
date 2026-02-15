//
//  OverlaySettingsTab.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import SwiftUI

struct OverlaySettingsTab: View {
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Focus Overlay
                OverlaySection(
                    title: "Focus Overlay",
                    isEnabled: $settings.focusOverlayEnabled,
                    hex: $settings.focusOverlayColorHex,
                    customImageEnabled: $settings
                        .focusOverlayCustomImageEnabled,
                    path: $settings.focusOverlayCustomImagePath,
                    imageName: $settings.focusOverlayImageName,
                    seconds: $settings.focusOverlaySeconds,
                    range: 3...60,
                    footer:
                        "Press ⌘⎋ (Cmd + Esc) or \"Dismiss\" or \"Start Now\" to dismiss."
                ) {
                    SettingsGridRow("Duration") {
                        HStack {
                            TextField(
                                "",
                                value: $settings.focusOverlaySeconds,
                                format: .number
                            )
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                            .multilineTextAlignment(.trailing)
                            .onSubmit {
                                settings.focusOverlaySeconds = settings
                                    .focusOverlaySeconds.clamped(to: 3...120)
                            }
                            Text("sec").foregroundStyle(.secondary)
                            Stepper(
                                "",
                                value: $settings.focusOverlaySeconds,
                                in: 3...120
                            )
                            .labelsHidden()
                        }
                    }

                    SettingsGridRow("Focus Message") {
                        TextField(
                            "e.g. Time to Focus!",
                            text: $settings.focusMessage
                        )
                        .textFieldStyle(.roundedBorder)
                    }
                }

                // Break Overlay
                OverlaySection(
                    title: "Break Overlay",
                    isEnabled: $settings.breakOverlayEnabled,
                    hex: $settings.breakOverlayColorHex,
                    customImageEnabled: $settings
                        .breakOverlayCustomImageEnabled,
                    path: $settings.breakOverlayCustomImagePath,
                    imageName: $settings.breakOverlayImageName,
                    seconds: $settings.breakOverlaySeconds,
                    range: 3...120,
                    footer: "Press ⌘⎋ (Cmd + Esc) or \"Dismiss\" to dismiss."
                ) {
                    SettingsGridRow("Duration Mode") {
                        Picker(
                            "",
                            selection: $settings.breakOverlayDurationMode
                        ) {
                            Text("Fixed seconds").tag(
                                BreakOverlayDurationMode.fixedSeconds
                            )
                            Text("Full break").tag(
                                BreakOverlayDurationMode.fullBreak
                            )
                        }
                        .pickerStyle(.segmented)
                    }

                    // Only show the Display Time row if we aren't in "Full Break" mode
                    if settings.breakOverlayDurationMode
                        == BreakOverlayDurationMode.fixedSeconds
                    {
                        SettingsGridRow("Duration") {
                            HStack {
                                TextField(
                                    "",
                                    value: $settings.breakOverlaySeconds,
                                    format: .number
                                )
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 50)
                                .multilineTextAlignment(.trailing)
                                .onSubmit {
                                    settings.breakOverlaySeconds = settings
                                        .breakOverlaySeconds.clamped(
                                            to: 3...120
                                        )
                                }
                                Text("sec").foregroundStyle(.secondary)
                                Stepper(
                                    "",
                                    value: $settings.breakOverlaySeconds,
                                    in: 3...120
                                )
                                .labelsHidden()
                            }
                        }
                    }

                    Toggle(
                        "Enable Dismiss Button",
                        isOn: $settings.breakOverlayShowDismissButton
                    )

                    SettingsGridRow("Short Break Msg") {
                        TextField(
                            "e.g. Take a breather",
                            text: $settings.sBreakMessage
                        )
                        .textFieldStyle(.roundedBorder)
                    }

                    SettingsGridRow("Long Break Msg") {
                        TextField(
                            "e.g. You earned this!",
                            text: $settings.lBreakMessage
                        )
                        .textFieldStyle(.roundedBorder)
                    }
                }
            }
        }
    }
}
