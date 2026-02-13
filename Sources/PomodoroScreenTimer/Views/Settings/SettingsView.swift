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
                    case .timer: TimerSettingsTab()
                    case .sounds: SoundSettingsTab()
                    case .overlays: OverlaySettingsTab()
                    case .startup: StartupSettingsTab()
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


}

