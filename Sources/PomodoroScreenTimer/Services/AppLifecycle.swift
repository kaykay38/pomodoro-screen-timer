//
//  AppLifecycle.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import AppKit

@MainActor
final class AppLifecycle: NSObject {
    static let shared = AppLifecycle()

    private var isObserving = false
    private weak var model: TimerModel?
    private var settings: SettingsStore?

    func startObserving(settings: SettingsStore, model: TimerModel) {
        guard !isObserving else { return }
        self.settings = settings
        self.model = model

        // Use selector-based API to avoid @Sendable closure + Sendable captures
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(appLaunched(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
        isObserving = true
    }

    @objc private func appLaunched(_ note: Notification) {
        guard
            let settings,
            settings.autoStartOnWatchedApps,
            let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
            let bid = app.bundleIdentifier
        else { return }

        if settings.watchedBundleIDs.contains(bid),
           let model, !model.isRunning {
            model.start()
        }
    }
}
