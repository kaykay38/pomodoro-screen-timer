//
//  SettingsView.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import Foundation
import SwiftUI

enum SettingsTab: String, CaseIterable {
    case timer = "Timer"
    case sounds = "Sounds"
    case overlays = "Overlays"
    case startup = "Startup"

    var systemImage: String {
        switch self {
        case .timer: return "timer"
        case .sounds: return "speaker.wave.2"
        case .overlays: return "photo"
        case .startup: return "power"
        }
    }
}

@MainActor
struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @State private var selectedTab: SettingsTab = .timer

    var body: some View {
        VStack(spacing: 0) {
            // Tab Picker (no label)
            Picker(selection: $selectedTab, label: EmptyView()) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Label(tab.rawValue, systemImage: tab.systemImage).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // Tab Content (centered)
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    switch selectedTab {
                    case .timer: timerTabContent
                    case .sounds: soundsTabContent
                    case .overlays: overlaysTabContent
                    case .startup: startupTabContent
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(20)
            }
        }
        .frame(
            minWidth: 420, idealWidth: 420, maxWidth: 420,
            minHeight: 420, idealHeight: 500, maxHeight: 800)
        .background(WindowBehaviorConfigurator(behavior: .floating))
    }

    // MARK: Tab Content Views

    @ViewBuilder
    private var timerTabContent: some View {
        VStack(spacing: 16) {
            Text("Durations")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

//            #if DEBUG
//            GroupBox {
//                Toggle("Test mode: treat minutes as seconds", isOn: $settings.devTreatMinutesAsSeconds)
//                    .tint(.pink)
//                Text("When ON, 25 min runs for 25 sec. Great for quick end-of-interval testing.")
//                    .font(.footnote)
//                    .foregroundStyle(.secondary)
//            }
//            #endif

            GroupBox {
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                    durationRow(
                        title: "Focus",
                        stepRange: 1...180,
                        binding: $settings.defaultFocusMinutes,
                        unit: "min")
                    durationRow(
                        title: "Short break",
                        stepRange: 1...60,
                        binding: $settings.defaultBreakMinutes,
                        unit: "min")
                    durationRow(
                        title: "Long break",
                        stepRange: 1...60,
                        binding: $settings.longBreakMinutes,
                        unit: "min")
                    durationRow(
                        title: "Cycles before long break",
                        stepRange: 1...10,
                        binding: $settings.cyclesUntilLongBreak,
                        unit: "")
                }
            }

            Text("Timer Behavior")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                Toggle("Auto-start next interval", isOn: $settings.autoCycleEnabled)
                Text(
                    "When enabled, the next timer interval starts automatically. When disabled, you'll need to manually start each interval."
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private var soundsTabContent: some View {
        VStack(spacing: 16) {
            Text("Sound Duration")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                HStack {
                    Slider(value: $settings.alarmDurationSeconds, in: 0...30, step: 0.5) {
                        Text("Alarm duration")
                    } minimumValueLabel: {
                        Text("0s")
                    } maximumValueLabel: {
                        Text("30s")
                    }
                    Text(
                        settings.alarmDurationSeconds == 0
                            ? "Full"
                            : String(format: "%.1fs", settings.alarmDurationSeconds)
                    )
                    .monospacedDigit()
                    .frame(width: 44, alignment: .trailing)
                }
                Text("Set to 0 seconds to play the full sound file length.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Text("Break Alarm (when focus ends)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                Picker("Sound", selection: $settings.breakAlarmSoundName) {
                    ForEach(SystemSounds.systemSounds, id: \.name) { sound in
                        Text(sound.displayName).tag(sound.name)
                    }
                }
                .pickerStyle(.menu)
                
                HStack {
                    Text("Custom sound file")
                    if settings.breakAlarmCustomSoundPath.isEmpty {
                        Button("Select File...") {
                            FileSelectionHelper.selectSoundFile { url in
                                guard let url,
                                      let copiedURL = FileSelectionHelper.copyFileToAppSupport(
                                        from: url, subfolder: "Sounds")
                                else { return }
                                DispatchQueue.main.async {
                                    settings.breakAlarmCustomSoundPath = copiedURL.path
                                }
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(
                                URL(fileURLWithPath: settings.breakAlarmCustomSoundPath)
                                    .lastPathComponent
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                            HStack {
                                Button("Change") {
                                    FileSelectionHelper.selectSoundFile { url in
                                        guard let url,
                                              let copiedURL =
                                                FileSelectionHelper.copyFileToAppSupport(
                                                    from: url, subfolder: "Sounds")
                                        else { return }
                                        DispatchQueue.main.async {
                                            settings.breakAlarmCustomSoundPath = copiedURL.path
                                        }
                                    }
                                }
                                Button("Remove") {
                                    settings.breakAlarmCustomSoundPath = ""
                                }
                            }
                        }
                    }
                }
                
                AlarmTestButton(
                    soundName: { settings.breakAlarmSoundName },
                    fileExtension: { settings.breakAlarmFileExtension },
                    customPath: { settings.breakAlarmCustomSoundPath },
                    durationSeconds: { settings.alarmDurationSeconds },
                    resolvedURL: {
                         settings.resolvedBreakSoundURL()
                    }
                )
            }

            Text("Focus Alarm (when break ends)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                Picker("Sound", selection: $settings.focusAlarmSoundName) {
                    ForEach(SystemSounds.systemSounds, id: \.name) { sound in
                        Text(sound.displayName).tag(sound.name)
                    }
                }
                .pickerStyle(.menu)
                
                HStack {
                    Text("Custom sound file")
                    if settings.focusAlarmCustomSoundPath.isEmpty {
                        Button("Select File...") {
                            FileSelectionHelper.selectSoundFile { url in
                                guard let url,
                                      let copiedURL = FileSelectionHelper.copyFileToAppSupport(
                                        from: url, subfolder: "Sounds")
                                else { return }
                                DispatchQueue.main.async {
                                    settings.focusAlarmCustomSoundPath = copiedURL.path
                                }
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(
                                URL(fileURLWithPath: settings.focusAlarmCustomSoundPath)
                                    .lastPathComponent
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                            HStack {
                                Button("Edit") {
                                    FileSelectionHelper.selectSoundFile { url in
                                        guard let url,
                                              let copiedURL =
                                                FileSelectionHelper.copyFileToAppSupport(
                                                    from: url, subfolder: "Sounds")
                                        else { return }
                                        DispatchQueue.main.async {
                                            settings.focusAlarmCustomSoundPath = copiedURL.path
                                        }
                                    }
                                }
                                Button("Remove") {
                                    settings.focusAlarmCustomSoundPath = ""
                                }
                            }
                        }
                    }
                }
                
                AlarmTestButton(
                    soundName: { settings.focusAlarmSoundName },
                    fileExtension: { settings.focusAlarmFileExtension },
                    customPath: { settings.focusAlarmCustomSoundPath },
                    durationSeconds: { settings.alarmDurationSeconds },
                    resolvedURL: {
                         settings.resolvedFocusSoundURL()
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var overlaysTabContent: some View {
        VStack(spacing: 16) {
            Text("Break Overlay")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                Toggle("Show break overlay", isOn: $settings.breakOverlayEnabled)

                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                    gridRowLabelValue("Background hex") {
                        TextField("#1E90FF", text: $settings.breakOverlayColorHex)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                    }
                    gridRowLabelValue("Custom image") {
                        if settings.breakOverlayCustomImagePath.isEmpty {
                            Button("Select Image...") {
                                FileSelectionHelper.selectImageFile { url in
                                    guard let url,
                                        let copiedURL = FileSelectionHelper.copyFileToAppSupport(
                                            from: url, subfolder: "Images")
                                    else { return }
                                    DispatchQueue.main.async {
                                        settings.breakOverlayCustomImagePath = copiedURL.path
                                        settings.breakOverlayImageName = copiedURL.path
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(
                                    URL(fileURLWithPath: settings.breakOverlayCustomImagePath)
                                        .lastPathComponent
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                                HStack {
                                    Button("Change") {
                                        FileSelectionHelper.selectImageFile { url in
                                            guard let url,
                                                let copiedURL =
                                                    FileSelectionHelper.copyFileToAppSupport(
                                                        from: url, subfolder: "Images")
                                            else { return }
                                            DispatchQueue.main.async {
                                                settings.breakOverlayCustomImagePath = copiedURL.path
                                                settings.breakOverlayImageName = copiedURL.path
                                            }
                                        }
                                    }
                                    Button("Remove") {
                                        settings.breakOverlayCustomImagePath = ""
                                        settings.breakOverlayImageName = ""
                                    }
                                }
                            }
                        }
                    }
                    gridRowLabelValue("Duration") {
                        VStack(alignment: .leading, spacing: 8) {
                            Picker(
                                selection: Binding(
                                    get: { settings.breakOverlayDurationMode },
                                    set: { settings.breakOverlayDurationMode = $0 }
                                ), label: EmptyView()
                            ) {
                                Text("Fixed seconds").tag(BreakOverlayDurationMode.fixedSeconds)
                                Text("Full break").tag(BreakOverlayDurationMode.fullBreak)
                            }
                            .pickerStyle(.segmented)

                            HStack {
                                TextField("", value: $settings.breakOverlaySeconds, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 50)
                                    .multilineTextAlignment(.trailing)
                                    .onSubmit {
                                        settings.breakOverlaySeconds = clamped(
                                            settings.breakOverlaySeconds, 3, 120)
                                    }
                                Text("sec").foregroundStyle(.secondary)
                                Stepper("", value: $settings.breakOverlaySeconds, in: 3...120)
                                    .labelsHidden()
                            }
                        }
                    }
                }

                Text("Leave image empty to use color. You can press ⎋ or \"Dismiss\".")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            }

            Text("Focus Overlay")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                Toggle("Show focus overlay", isOn: $settings.focusOverlayEnabled)

                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                    gridRowLabelValue("Background hex") {
                        TextField("#111827", text: $settings.focusOverlayColorHex)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                    }
                    gridRowLabelValue("Custom image") {
                        if settings.focusOverlayCustomImagePath.isEmpty {
                            Button("Select Image...") {
                                FileSelectionHelper.selectImageFile { url in
                                    guard let url,
                                        let copiedURL = FileSelectionHelper.copyFileToAppSupport(
                                            from: url, subfolder: "Images")
                                    else { return }
                                    DispatchQueue.main.async {
                                        settings.focusOverlayCustomImagePath = copiedURL.path
                                        settings.focusOverlayImageName = copiedURL.path
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(
                                    URL(fileURLWithPath: settings.focusOverlayCustomImagePath)
                                        .lastPathComponent
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                                HStack {
                                    Button("Edit") {
                                        FileSelectionHelper.selectImageFile { url in
                                            guard let url,
                                                let copiedURL =
                                                    FileSelectionHelper.copyFileToAppSupport(
                                                        from: url, subfolder: "Images")
                                            else { return }
                                            DispatchQueue.main.async {
                                                settings.focusOverlayCustomImagePath = copiedURL.path
                                                settings.focusOverlayImageName = copiedURL.path
                                            }
                                        }
                                    }
                                    Button("Remove") {
                                        settings.focusOverlayCustomImagePath = ""
                                        settings.focusOverlayImageName = ""
                                    }
                                }
                            }
                        }
                    }
                    gridRowLabelValue("Duration") {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                TextField("", value: $settings.focusOverlaySeconds, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 50)
                                    .multilineTextAlignment(.trailing)
                                    .onSubmit {
                                        settings.focusOverlaySeconds = clamped(
                                            settings.focusOverlaySeconds, 3, 60)
                                    }
                                Text("sec").foregroundStyle(.secondary)
                                Stepper("", value: $settings.focusOverlaySeconds, in: 3...60)
                                    .labelsHidden()
                            }
                        }
                    }
                }

                Text("Leave image empty to use color. You can press ⎋ or \"Start Now\".")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)
            }
        }
    }

    @ViewBuilder
    private var startupTabContent: some View {
        VStack(spacing: 16) {
            Text("Startup")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    .onChange(of: settings.launchAtLogin) { oldValue, newValue in
                        settings.applyLaunchAtLogin(newValue)
                        print("[DEBUG] Launch at login: \(newValue)")
                    }
            }
        }
    }

    // MARK: Helper Methods

    private func durationRow(
        title: String,
        stepRange: ClosedRange<Int>,
        binding: Binding<Int>,
        unit: String
    ) -> some View {
        GridRow {
            Text(title)
            HStack(spacing: 8) {
                TextField("", value: binding, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 50)
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        binding.wrappedValue = clamped(
                            binding.wrappedValue,
                            stepRange.lowerBound,
                            stepRange.upperBound)
                    }

                if !unit.isEmpty {
                    Text(unit).foregroundStyle(.secondary)
                }

                Stepper("", value: binding, in: stepRange)
                    .labelsHidden()
            }
        }
    }

    private func gridRowLabelValue<Content: View>(
        _ label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        GridRow {
            Text(label)
            content()
        }
    }

    @inline(__always)
    private func clamped(_ x: Int, _ lo: Int, _ hi: Int) -> Int {
        min(max(x, lo), hi)
    }
}

private struct AlarmTestButton: View {
    var label: String = "Test Sound"

    // Provide current values via closures so this stays generic.
    var soundName: () -> String          = { "" }
    var fileExtension: () -> String      = { "" }
    var customPath: () -> String         = { "" }
    var durationSeconds: () -> Double    = { 0 }
    /// If you have bookmark helpers (e.g. settings.resolvedBreakSoundURL), return it here; else return nil.
    var resolvedURL: () -> URL?          = { nil }

    @State private var handle: AlarmHandle?

    var body: some View {
        Button(handle == nil ? label : "Stop") {
            if let h = handle {
                AlarmPlayer.stop(handle: h)       // stop ONLY this preview
                handle = nil
            } else {
                let dur = durationSeconds()
                // Cap preview: if 0 means loop, use ~5s; otherwise limit to 10s for UX
                let preview = dur == 0 ? 5.0 : min(dur, 10.0)

                if let url = resolvedURL() {
                    handle = AlarmPlayer.play(url: url, duration: preview)
                } else {
                    handle = AlarmPlayer.play(
                        soundName: soundName(),
                        fileExtension: fileExtension(),
                        customSoundPath: customPath(),
                        duration: preview
                    )
                }
                
                // Avoid retain/cross-run confusion: capture the ID
                let id = handle?.id
                handle?.onStop = { [id] in
                    if handle?.id == id { handle = nil }   // flips the button title back to "Test"
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .onDisappear {
            if let h = handle {
                AlarmPlayer.stop(handle: h)       // cleanup if user navigates away
                handle = nil
            }
        }
        .accessibilityIdentifier("alarmTestButton")
    }
}
