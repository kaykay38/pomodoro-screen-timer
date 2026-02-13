//
//  SoundSettingsTab.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import SwiftUI

struct SoundSettingsTab: View {
    @EnvironmentObject var settings: SettingsStore
    @State private var testMessage: String = "Time to focus!"
    @State private var voiceID: String? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 1. Duration Slider
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sound Duration").font(.headline)
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Slider(
                                    value: $settings.alarmDurationSeconds,
                                    in: 0...30,
                                    step: 0.5
                                )
                                Text(
                                    settings.alarmDurationSeconds == 0
                                        ? "Full"
                                        : String(
                                            format: "%.1fs",
                                            settings.alarmDurationSeconds
                                        )
                                )
                                .monospacedDigit()
                                .frame(width: 44, alignment: .trailing)
                            }
                            Text(
                                "Set to 0 seconds to play the full sound file length."
                            )
                            .font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }

                // 2. Break Alarm Section
                SoundPickerSection(
                    title: "Break Alarm (when focus ends)",
                    subtitle: "Plays when focus session ends.",
                    selectedSoundName: $settings.breakAlarmSoundName,
                    customSoundEnabled: $settings.breakAlarmCustomSoundEnabled,
                    customPath: $settings.breakAlarmCustomSoundPath,
                    fileExtension: settings.breakAlarmFileExtension,
                    alarmDuration: settings.alarmDurationSeconds,
                    resolvedURL: settings.resolvedBreakSoundURL()
                )

                // 3. Focus Alarm Section
                SoundPickerSection(
                    title: "Focus Alarm",
                    subtitle: "Plays when break session ends.",
                    selectedSoundName: $settings.focusAlarmSoundName,
                    customSoundEnabled: $settings.focusAlarmCustomSoundEnabled,
                    customPath: $settings.focusAlarmCustomSoundPath,
                    fileExtension: settings.focusAlarmFileExtension,
                    alarmDuration: settings.alarmDurationSeconds,
                    resolvedURL: settings.resolvedFocusSoundURL()
                )

                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Voice Alert")
                            .font(.headline)
                        Text(
                            "When enabled, the alarm will play for 3 seconds, then will speak the text on the overlay."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(
                                "Enable Voice Alert for Focus",
                                isOn: $settings.focusMessageVoiceEnabled
                            )
                            if settings.focusMessageVoiceEnabled {
                                VoicePicker(
                                    title: "Focus Voice",
                                    selectedID: $settings.focusMessageVoiceID
                                )
                            }

                            Divider()

                            Toggle(
                                "Enable Voice Alert for Breaks",
                                isOn: $settings.breakMessageVoiceEnabled
                            )
                            if settings.breakMessageVoiceEnabled {
                                VoicePicker(
                                    title: "Break Voice",
                                    selectedID: $settings.breakMessageVoiceID
                                )
                            }
                        }

                        if settings.breakMessageVoiceEnabled
                            || settings.focusMessageVoiceEnabled
                        {
                            Divider()

                            Text("Test Voice").font(.headline)
                            VStack(alignment: .leading, spacing: 8) {
                                VoicePicker(
                                    title: "Voices",
                                    selectedID: $voiceID
                                )
                                .onChange(of: voiceID) { _, _ in
                                    SpeechSynthesizer.shared.stop()  // Stop speaking if the voice changes
                                }
                                HStack {
                                    TextField(
                                        "Test Message",
                                        text: $testMessage
                                    )
                                    .textFieldStyle(.roundedBorder)
                                    Button {
                                        if SpeechSynthesizer.shared.isSpeaking {
                                            SpeechSynthesizer.shared.stop()
                                        } else {
                                            SpeechSynthesizer.shared.speak(
                                                testMessage,
                                                voiceID: voiceID
                                            )
                                        }
                                    } label: {
                                        Label(
                                            SpeechSynthesizer.shared.isSpeaking
                                                ? "Stop" : "Play",
                                            systemImage: SpeechSynthesizer
                                                .shared
                                                .isSpeaking
                                                ? "stop.fill" : "play.fill"
                                        )
                                    }
                                    .disabled(testMessage.isEmpty)
                                }
                            }

                        }
                    }
                }
            }
        }
    }
}
