//
//  SoundPickerSection.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import SwiftUI

struct SoundPickerSection: View {
    let title: String
    let subtitle: String
    @Binding var selectedSoundName: String
    @Binding var customSoundEnabled: Bool  // New binding for the toggle
    @Binding var customPath: String
    var fileExtension: String
    var alarmDuration: Double
    var resolvedURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    // Source Toggle (Segmented Picker)
                    Picker("Sound Source", selection: $customSoundEnabled) {
                        Text("System").tag(false)
                        Text("Custom").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: customSoundEnabled) { _, _ in
                        AlarmPlayer.stop()
                    }

                    if !customSoundEnabled {
                        // System Sound Menu
                        Picker("Sound", selection: $selectedSoundName) {
                            ForEach(SystemSounds.systemSounds, id: \.name) {
                                sound in
                                Text(sound.displayName).tag(sound.name)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: selectedSoundName) { _, _ in
                            AlarmPlayer.stop()
                        }
                    } else {
                        // Custom File UI
                        HStack {
                            Text("Custom sound file")
                            Spacer()
                            if customPath.isEmpty {
                                Button("Select File...") { selectFile() }
                            } else {
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(
                                        URL(fileURLWithPath: customPath)
                                            .lastPathComponent
                                    )
                                    .font(.caption).foregroundColor(.secondary)
                                    HStack {
                                        Button("Change") { selectFile() }
                                        Button("Remove") { customPath = "" }
                                    }
                                }
                            }
                        }
                    }

                    Divider()

                    let selectedSystemSoundURL = SystemSounds.systemSounds
                        .first(where: { $0.name == selectedSoundName })?.url

                    AlarmTestButton(
                        label:
                            "Test \(customSoundEnabled ? "Custom" : "System") Sound",
                        soundName: {
                            customSoundEnabled ? "" : selectedSoundName
                        },
                        fileExtension: {
                            customSoundEnabled ? "" : fileExtension
                        },
                        customPath: { customSoundEnabled ? customPath : "" },
                        durationSeconds: { alarmDuration },
                        resolvedURL: {
                            if customSoundEnabled {
                                return resolvedURL  // Your custom file URL
                            } else {
                                return selectedSystemSoundURL  // The system .m4r URL we found
                            }
                        }
                    )
                    .frame(maxWidth: .infinity)
                    .id(
                        "\(selectedSoundName)-\(customSoundEnabled)-\(customPath)"
                    )
                }
            }
        }
    }

    private func selectFile() {
        // Grab the current window from the NSApplication
        let currentWindow = NSApp.windows.first { $0.isKeyWindow }

        FileSelectionHelper.selectSoundFile(in: currentWindow) { url in
            guard let url,
                let copiedURL = FileSelectionHelper.copyFileToAppSupport(
                    from: url,
                    subfolder: "Sounds"
                )
            else { return }
            DispatchQueue.main.async { self.customPath = copiedURL.path }
        }
    }
}
