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
        Group {
            Button(model.isRunning ? "Pause" : "Start") { model.toggleStartStop() }
                .keyboardShortcut(.space, modifiers: [])

            Button("Stop") { model.stop() }
                .disabled(!model.isRunning)
                .keyboardShortcut("s", modifiers: .command)

            Divider()

            Button("Reset to Focus") { model.resetToFocus() }
            Button("Reset to Break") { model.resetToBreak() }

            Divider()

            Button("Show App") {
                openWindow(id: "main")     // ← the exact same window definition as startup
            }
            .keyboardShortcut("o", modifiers: .command)

            Divider()
            
            Button {} label: {
                HStack {
                    Text("Focus:   \(model.completedFocusCount)")
                        .monospacedDigit()
                }
            }
            .buttonStyle(.plain)
            .allowsHitTesting(false)

            Button {} label: {
                HStack {
                    Text("Breaks:  \(model.completedBreakCount)")
                        .monospacedDigit()
                }
            }
            .buttonStyle(.plain)
            .allowsHitTesting(false)

            Divider()
            
            SettingsLink { Text("Settings…") }
                .keyboardShortcut(",", modifiers: .command)
            
            Divider()

            Button("Quit") { NSApp.terminate(nil) }
                .keyboardShortcut("q", modifiers: .command)
        }
        .frame(minWidth: 180)
    }
}
