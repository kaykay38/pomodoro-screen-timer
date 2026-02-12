//
//  Pomodoro_Screen_TimerApp.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import SwiftUI
import AppKit

@main
struct Pomodoro_Screen_TimerApp: App {
    @StateObject private var settings: SettingsStore
    @StateObject private var model: TimerModel
    
    init() {
        let s = SettingsStore()
        let m = TimerModel(settings: s)
        
        _settings = StateObject(wrappedValue: s)
        _model    = StateObject(wrappedValue: m)
        
        AppLifecycle.shared.startObserving(
            settings: s,
            model: m
        )
        
        DispatchQueue.main.async { NSApp.setActivationPolicy(.accessory) } // menu-bar–only app
    }
    
    var body: some Scene {
        // Native menubar (real NSMenu items with .menu style)
        MenuBarExtra {
            MenuBarView()
                .environmentObject(settings)
                .environmentObject(model)
        } label: {
            MenuBarStatusLabel().environmentObject(model)
        }
        .menuBarExtraStyle(.menu)
        
        // SINGLE main window (singleton)
        Window("Pomodoro Screen Timer", id: "main") {
            MainView()
                .environmentObject(settings)
                .environmentObject(model)
        }
        .defaultSize(width: 520, height: 560)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        
        Settings {
            SettingsView()
                .environmentObject(settings)
                .environmentObject(model)
        }
    }
}

// requires AppKit
private func statusTextWidth(template: String = "360:00",
                             font: NSFont = .monospacedSystemFont(ofSize: 12, weight: .medium)) -> CGFloat {
    let w = (template as NSString).size(withAttributes: [.font: font]).width
    return ceil(w) + 8  // padding so it doesn't feel cramped
}
