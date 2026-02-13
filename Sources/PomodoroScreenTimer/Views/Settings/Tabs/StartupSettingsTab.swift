//
//  StartupSettingsTab.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import SwiftUI

struct StartupSettingsTab: View {

    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        VStack(spacing: 16) {
            Text("Startup")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            GroupBox {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    .onChange(of: settings.launchAtLogin) {
                        oldValue,
                        newValue in
                        settings.applyLaunchAtLogin(newValue)
                        print("[DEBUG] Launch at login: \(newValue)")
                    }
            }
        }
    }
}

// MARK: Helper Methods
