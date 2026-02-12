//
//  MainView.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var model: TimerModel

    var body: some View {
        VStack(spacing: 16) {
            // Ring with embedded time, phase text, and colored play/pause
            ProgressRingView(
                progress: progress,
                phase: model.phase,
                size: 320,
                centerText: timeString(model.remaining),
                isRunning: model.isRunning,
                onToggle: { model.toggleStartStop() }
            ).padding(.vertical , 16)

            // Display number of completed focus, short break, long break segments
            HStack(spacing: 24) {
                statItem(
                    value: model.completedFocusCount,
                    label: "Focus",
                    systemImage: "brain.head.profile"
                )

                statItem(
                    value: model.completedShortBreakCount,
                    label: "Short",
                    systemImage: "cup.and.saucer"
                )

                statItem(
                    value: model.completedLongBreakCount,
                    label: "Long",
                    systemImage: "figure.walk"
                )
            }
            .padding(.top, 4)
            
            // Phase + Minutes
            HStack(spacing: 16) {
                Picker("Phase", selection: $model.phase) {
                    Text("Focus").tag(Phase.focus)
                    Text("Break").tag(Phase.shortBreak)
                    Text("Long").tag(Phase.longBreak)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 300)
                
                HStack(spacing: 10) {
                    Image(systemName: "clock").foregroundStyle(.secondary)
                    TextField("Min", value: Binding(
                        get: { model.totalSeconds / 60 },
                        set: { model.setMinutes(max(1, min(360, $0))) }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
                    .multilineTextAlignment(.center)

                    Stepper("", value: Binding(
                        get: { model.totalSeconds / 60 },
                        set: { model.setMinutes($0) }
                    ), in: 1...360, step: settings.minuteStep)
                    .labelsHidden()
                }
                .disabled(model.isRunning)
            }

            // Secondary actions
            HStack(spacing: 12) {
                Button {
                    model.reset(for: model.phase)
                } label: {
                    Label("Reset", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)

                SettingsLink {
                    Label("Settings", systemImage: "gearshape")
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .frame(minWidth: 460, minHeight: 420)
        .onAppear { if !model.isRunning { model.remaining = model.totalSeconds } }
        .background(WindowBehaviorConfigurator(behavior: .floating))
    }

    private var progress: Double {
        guard model.totalSeconds > 0 else { return 0 }
        return 1 - Double(model.remaining) / Double(model.totalSeconds)
    }
    
    private func timeString(_ s: Int) -> String { String(format: "%02d:%02d", s/60, s%60) }
    
    @ViewBuilder
    private func statItem(value: Int, label: String, systemImage: String) -> some View {
        VStack(spacing: 2) {
            Label {
                Text("\(value)")
                    .font(.headline)
            } icon: {
                Image(systemName: systemImage)
            }
            .labelStyle(.titleAndIcon)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
