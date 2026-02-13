//
//  OverlaySection.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import SwiftUI

struct OverlaySection<Content: View>: View {
    let title: String
    @Binding var isEnabled: Bool
    @Binding var hex: String
    @Binding var customImageEnabled: Bool
    @Binding var path: String
    @Binding var imageName: String
    @Binding var seconds: Int
    let range: ClosedRange<Int>
    let footer: String
    let extraContent: Content

    init(
        title: String,
        isEnabled: Binding<Bool>,
        hex: Binding<String>,
        customImageEnabled: Binding<Bool>,
        path: Binding<String>,
        imageName: Binding<String>,
        seconds: Binding<Int>,
        range: ClosedRange<Int>,
        footer: String,
        @ViewBuilder extraContent: () -> Content = { EmptyView() }
    ) {
        self.title = title
        self._isEnabled = isEnabled
        self._hex = hex
        self._customImageEnabled = customImageEnabled
        self._path = path
        self._imageName = imageName
        self._seconds = seconds
        self.range = range
        self.footer = footer
        self.extraContent = extraContent()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)

            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable overlay", isOn: $isEnabled)

                    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                        Picker("Overlay Type", selection: $customImageEnabled) {
                            Text("Color Overlay").tag(false)
                            Text("Custom Image").tag(true)
                        }
                        .pickerStyle(.segmented)
                        
                        if !customImageEnabled {
                            SettingsGridRow("Background hex") {
                                TextField("#Hex", text: $hex)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 120)
                            }
                        }
                        else{
                            ImagePickerRow(label: "Custom image", path: $path, imageName: $imageName)
                        }

                        extraContent
                    }
                    
                    Text(footer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
    }
}
