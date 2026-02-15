//
//  MenuBarView.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/17/25.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var model: TimerModel
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.openWindow) private var openWindow

    var body: some View {

        Button(model.isRunning ? "Pause" : "Start") {
            model.toggleStartStop()
        }
        .keyboardShortcut(.space, modifiers: [])

        Button("Stop") { model.stop() }
            .disabled(!model.isRunning)
            .keyboardShortcut("s", modifiers: .command)

        Divider()

        Button("Reset to Focus") { model.resetToFocus() }
        Button("Reset to Break") { model.resetToBreak() }

        Divider()

        Button("Show App") {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)  // Brings the window to the front
        }
        .keyboardShortcut("o", modifiers: .command)

        Divider()

        Section("Session Stats") {
            Text("Focus:   \(model.completedFocusCount)")
                .monospacedDigit()
            Text("Short Breaks:  \(model.completedShortBreakCount)")
                .monospacedDigit()
            Text("Long Breaks:  \(model.completedLongBreakCount)")
                .monospacedDigit()
        }

        Divider()

        SettingsLink { Text("Settings…") }
            .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button("Quit") { NSApp.terminate(nil) }
            .keyboardShortcut("q", modifiers: .command)

    }
}
