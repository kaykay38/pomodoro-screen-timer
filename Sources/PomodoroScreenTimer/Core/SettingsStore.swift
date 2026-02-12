//
//  SettingsStore.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import AppKit
import Combine
import Foundation
import ServiceManagement
import SwiftUI

enum BreakOverlayDurationMode: String {
    case fullBreak  // lasts for entire break
    case fixedSeconds  // lasts for N seconds, then auto-dismiss
}

final class SettingsStore: ObservableObject {
    @Published var devTreatMinutesAsSeconds: Bool = false

    // Durations & step
    @Published var defaultFocusMinutes: Int = UserDefaults.standard.integer(
        forKey: "defaultfocusMinutes"
    ).nonZeroOr(25)
    {
        didSet {
            UserDefaults.standard.set(
                defaultFocusMinutes,
                forKey: "defaultFocusMinutes"
            )
        }
    }
    @Published var defaultBreakMinutes: Int = UserDefaults.standard.integer(
        forKey: "defaultBreakMinutes"
    ).nonZeroOr(5)
    {
        didSet {
            UserDefaults.standard.set(
                defaultBreakMinutes,
                forKey: "defaultBreakMinutes"
            )
        }
    }
    @Published var longBreakMinutes: Int = UserDefaults.standard.integer(
        forKey: "longBreakMinutes"
    ).nonZeroOr(15)
    {
        didSet {
            UserDefaults.standard.set(
                longBreakMinutes,
                forKey: "longBreakMinutes"
            )
        }
    }
    @Published var cyclesUntilLongBreak: Int = UserDefaults.standard.integer(
        forKey: "cyclesUntilLongBreak"
    ).nonZeroOr(4)
    {
        didSet {
            UserDefaults.standard.set(
                cyclesUntilLongBreak,
                forKey: "cyclesUntilLongBreak"
            )
        }
    }
    @Published var minuteStep: Int = UserDefaults.standard.integer(
        forKey: "minuteStep"
    ).nonZeroOr(5)
    { didSet { UserDefaults.standard.set(minuteStep, forKey: "minuteStep") } }

    // Login Item
    @Published var launchAtLogin: Bool = LoginItemManager.isEnabled

    func applyLaunchAtLogin(_ enabled: Bool) {
        do {
            try LoginItemManager.set(enabled: enabled)
            // optional: refresh from system status to keep in sync
            self.launchAtLogin = LoginItemManager.isEnabled
        } catch {
            NSLog("Failed to set login item: \(error)")
            // revert UI
            self.launchAtLogin = LoginItemManager.isEnabled
        }
    }

    // Startup & triggers
    @Published var startTimerOnLaunch: Bool = UserDefaults.standard.bool(
        forKey: "startTimerOnLaunch"
    )
    {
        didSet {
            UserDefaults.standard.set(
                startTimerOnLaunch,
                forKey: "startTimerOnLaunch"
            )
        }
    }

    @Published var autoStartOnWatchedApps: Bool = UserDefaults.standard.bool(
        forKey: "autoStartOnWatchedApps"
    )
    {
        didSet {
            UserDefaults.standard.set(
                autoStartOnWatchedApps,
                forKey: "autoStartOnWatchedApps"
            )
        }
    }
    @Published var watchedBundleIDs: [String] =
        UserDefaults.standard.stringArray(forKey: "watchedBundleIDs") ?? [
            "org.mozilla.firefox", "com.microsoft.VSCode",
        ]
    {
        didSet {
            UserDefaults.standard.set(
                watchedBundleIDs,
                forKey: "watchedBundleIDs"
            )
        }
    }

    // Auto‑cycle
    @Published var autoCycleEnabled: Bool =
        UserDefaults.standard.object(forKey: "autoCycleEnabled") as? Bool
        ?? true
    {
        didSet {
            UserDefaults.standard.set(
                autoCycleEnabled,
                forKey: "autoCycleEnabled"
            )
        }
    }

    // Break Message displays on Overlay
    @Published var sBreakMessage: String =
        UserDefaults.standard.string(forKey: "sBreakMessage") ?? "Take a break"
    {
        didSet {
            UserDefaults.standard.set(sBreakMessage, forKey: "sBreakMessage")
        }
    }
    
    // Break Message displays on Overlay
    @Published var lBreakMessage: String =
        UserDefaults.standard.string(forKey: "lBreakMessage") ?? "Refresh your mind, take a longer break"
    {
        didSet {
            UserDefaults.standard.set(lBreakMessage, forKey: "lBreakMessage")
        }
    }

    @Published var breakMessageVoiceEnabled: Bool =
        UserDefaults.standard.object(forKey: "breakMessageVoiceEnabled")
        as? Bool ?? true
    {
        didSet {
            UserDefaults.standard.set(
                breakMessageVoiceEnabled,
                forKey: "breakMessageVoiceEnabled"
            )
        }
    }
    // Break overlay
    @Published var breakOverlayEnabled: Bool =
        UserDefaults.standard.object(forKey: "breakOverlayEnabled") as? Bool
        ?? true
    {
        didSet {
            UserDefaults.standard.set(
                breakOverlayEnabled,
                forKey: "breakOverlayEnabled"
            )
        }
    }
    @Published var breakOverlayColorHex: String =
        UserDefaults.standard.string(forKey: "breakOverlayColorHex")
        ?? "#1E90FF"
    {
        didSet {
            UserDefaults.standard.set(
                breakOverlayColorHex,
                forKey: "breakOverlayColorHex"
            )
        }
    }
    @Published var breakOverlayImageName: String =
        UserDefaults.standard.string(forKey: "breakOverlayImageName") ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                breakOverlayImageName,
                forKey: "breakOverlayImageName"
            )
        }
    }
    @Published var breakOverlayCustomImagePath: String =
        UserDefaults.standard.string(forKey: "breakOverlayCustomImagePath")
        ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                breakOverlayCustomImagePath,
                forKey: "breakOverlayCustomImagePath"
            )
        }
    }
    @Published var breakOverlayDurationModeRaw: String =
        UserDefaults.standard.string(forKey: "breakOverlayDurationModeRaw")
        ?? BreakOverlayDurationMode.fixedSeconds.rawValue
    {
        didSet {
            UserDefaults.standard.set(
                breakOverlayDurationModeRaw,
                forKey: "breakOverlayDurationModeRaw"
            )
        }
    }
    var breakOverlayDurationMode: BreakOverlayDurationMode {
        get {
            BreakOverlayDurationMode(rawValue: breakOverlayDurationModeRaw)
                ?? .fixedSeconds
        }
        set { breakOverlayDurationModeRaw = newValue.rawValue }
    }
    @Published var breakOverlaySeconds: Int = UserDefaults.standard.integer(
        forKey: "breakOverlaySeconds"
    ).nonZeroOr(4)
    {
        didSet {
            UserDefaults.standard.set(
                breakOverlaySeconds,
                forKey: "breakOverlaySeconds"
            )
        }
    }
    @Published var breakOverlayShowDismissButton: Bool =
        UserDefaults.standard.object(forKey: "breakOverlayShowDismissButton")
        as? Bool ?? true
    {
        didSet {
            UserDefaults.standard.set(
                breakOverlayShowDismissButton,
                forKey: "breakOverlayShowDismissButton"
            )
        }
    }

    // Focus
    // Break Message displays on Overlay
    @Published var focusMessage: String =
        UserDefaults.standard.string(forKey: "focusMessage") ?? "Back to work!"
    {
        didSet {
            UserDefaults.standard.set(focusMessage, forKey: "focusMessage")
        }
    }
    @Published var focusMessageVoiceEnabled: Bool =
        (UserDefaults.standard.object(forKey: "focusMessageVoiceEnabled")
            as? Bool) ?? true
    {
        didSet {
            UserDefaults.standard.set(
                focusMessageVoiceEnabled,
                forKey: "focusMessageVoiceEnabled"
            )
        }
    }
    // Focus overlay (at end of break)
    @Published var focusOverlayEnabled: Bool =
        (UserDefaults.standard.object(forKey: "focusOverlayEnabled") as? Bool)
        ?? true
    {
        didSet {
            UserDefaults.standard.set(
                focusOverlayEnabled,
                forKey: "focusOverlayEnabled"
            )
        }
    }
    @Published var focusOverlaySeconds: Int = UserDefaults.standard.integer(
        forKey: "focusOverlaySeconds"
    ).nonZeroOr(4)
    {
        didSet {
            UserDefaults.standard.set(
                focusOverlaySeconds,
                forKey: "focusOverlaySeconds"
            )
        }
    }
    @Published var focusOverlayColorHex: String =
        UserDefaults.standard.string(forKey: "focusOverlayColorHex")
        ?? "#111827"
    {
        didSet {
            UserDefaults.standard.set(
                focusOverlayColorHex,
                forKey: "focusOverlayColorHex"
            )
        }
    }
    @Published var focusOverlayImageName: String =
        UserDefaults.standard.string(forKey: "focusOverlayImageName") ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                focusOverlayImageName,
                forKey: "focusOverlayImageName"
            )
        }
    }
    // Custom focus overlay image path
    @Published var focusOverlayCustomImagePath: String =
        UserDefaults.standard.string(forKey: "focusOverlayCustomImagePath")
        ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                focusOverlayCustomImagePath,
                forKey: "focusOverlayCustomImagePath"
            )
        }
    }

    // Break Alarm
    @Published var breakAlarmCustomSoundEnabled: Bool =
        (UserDefaults.standard.object(forKey: "breakAlarmCustomSoundEnabled")
            as? Bool) ?? true
    {
        didSet {
            UserDefaults.standard.set(
                breakAlarmCustomSoundEnabled,
                forKey: "breakAlarmCustomSoundEnabled"
            )
        }
    }
    @Published var breakAlarmSoundName: String =
        UserDefaults.standard.string(forKey: "breakAlarmSoundName") ?? "Sosumi"
    {
        didSet {
            UserDefaults.standard.set(
                breakAlarmSoundName,
                forKey: "breakAlarmSoundName"
            )
        }
    }
    @Published var breakAlarmFileExtension: String =
        UserDefaults.standard.string(forKey: "breakAlarmFileExtension") ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                breakAlarmFileExtension,
                forKey: "breakAlarmFileExtension"
            )
        }
    }
    @Published var breakAlarmCustomSoundPath: String =
        UserDefaults.standard.string(forKey: "breakAlarmCustomSoundPath") ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                breakAlarmCustomSoundPath,
                forKey: "breakAlarmCustomSoundPath"
            )
        }
    }

    // Focus Alarm
    @Published var focusAlarmCustomSoundEnabled: Bool =
        (UserDefaults.standard.object(forKey: "focusAlarmCustomSoundEnabled")
            as? Bool) ?? true
    {
        didSet {
            UserDefaults.standard.set(
                focusAlarmCustomSoundEnabled,
                forKey: "focusAlarmCustomSoundEnabled"
            )
        }
    }
    @Published var focusAlarmSoundName: String =
        UserDefaults.standard.string(forKey: "focusAlarmSoundName") ?? "Bell"
    {
        didSet {
            UserDefaults.standard.set(
                focusAlarmSoundName,
                forKey: "focusAlarmSoundName"
            )
        }
    }
    @Published var focusAlarmFileExtension: String =
        UserDefaults.standard.string(forKey: "focusAlarmFileExtension") ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                focusAlarmFileExtension,
                forKey: "focusAlarmFileExtension"
            )
        }
    }
    @Published var focusAlarmCustomSoundPath: String =
        UserDefaults.standard.string(forKey: "focusAlarmCustomSoundPath") ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                focusAlarmCustomSoundPath,
                forKey: "focusAlarmCustomSoundPath"
            )
        }
    }

    // Sound Duration (in seconds, 0 means full file length)
    @Published var alarmDurationSeconds: Double =
        UserDefaults.standard.object(forKey: "alarmDurationSeconds") as? Double
        ?? 3.0
    {
        didSet {
            UserDefaults.standard.set(
                alarmDurationSeconds,
                forKey: "alarmDurationSeconds"
            )
        }
    }

    // Legacy alarm settings for backward compatibility
    @Published var alarmSoundName: String =
        UserDefaults.standard.string(forKey: "alarmSoundName") ?? "Sosumi"
    {
        didSet {
            UserDefaults.standard.set(alarmSoundName, forKey: "alarmSoundName")
        }
    }
    @Published var alarmFileExtension: String =
        UserDefaults.standard.string(forKey: "alarmFileExtension") ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                alarmFileExtension,
                forKey: "alarmFileExtension"
            )
        }
    }
    @Published var customSoundPath: String =
        UserDefaults.standard.string(forKey: "customSoundPath") ?? ""
    {
        didSet {
            UserDefaults.standard.set(
                customSoundPath,
                forKey: "customSoundPath"
            )
        }
    }
    // Persisted security-scoped bookmarks (Data is fine in UserDefaults)
    @Published var breakSoundBookmark: Data? = UserDefaults.standard.data(
        forKey: "breakSoundBookmark"
    )
    {
        didSet {
            UserDefaults.standard.set(
                breakSoundBookmark,
                forKey: "breakSoundBookmark"
            )
        }
    }
    @Published var focusSoundBookmark: Data? = UserDefaults.standard.data(
        forKey: "focusSoundBookmark"
    )
    {
        didSet {
            UserDefaults.standard.set(
                focusSoundBookmark,
                forKey: "focusSoundBookmark"
            )
        }
    }

    // MARK: Bookmark helpers

    /// Call this right after user picks a break sound file in NSOpenPanel.
    func setBreakAlarmCustomSound(url: URL) {
        if let (bookmark, path) = Self.makeBookmark(for: url) {
            breakSoundBookmark = bookmark
            breakAlarmCustomSoundPath = path  // keep path for display/debug
        }
    }

    /// Call this right after user picks a focus sound file in NSOpenPanel.
    func setFocusAlarmCustomSound(url: URL) {
        if let (bookmark, path) = Self.makeBookmark(for: url) {
            focusSoundBookmark = bookmark
            focusAlarmCustomSoundPath = path
        }
    }

    /// Use this when you need the actual Break URL to play.
    func resolvedBreakSoundURL() -> URL? {
        Self.resolveBookmark(breakSoundBookmark)
            ?? pathToURLIfPermitted(breakAlarmCustomSoundPath)
    }

    /// Use this when you need the actual Focus URL to play.
    func resolvedFocusSoundURL() -> URL? {
        Self.resolveBookmark(focusSoundBookmark)
            ?? pathToURLIfPermitted(focusAlarmCustomSoundPath)
    }

    // Fallback if file is inside app container or permission already granted
    private func pathToURLIfPermitted(_ path: String) -> URL? {
        guard !path.isEmpty else { return nil }
        let u = URL(fileURLWithPath: path)
        return FileManager.default.isReadableFile(atPath: u.path) ? u : nil
    }

    // Static helpers
    private static func makeBookmark(for url: URL) -> (Data, String)? {
        do {
            let data = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            return (data, url.path)
        } catch {
            print("[BOOKMARK ERROR] makeBookmark: \(error)")
            return nil
        }
    }

    private static func resolveBookmark(_ data: Data?) -> URL? {
        guard let data else { return nil }
        var stale = false
        do {
            let url = try URL(
                resolvingBookmarkData: data,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &stale
            )
            _ = url.startAccessingSecurityScopedResource()  // intentionally long-lived
            return url
        } catch {
            print("[BOOKMARK ERROR] resolve: \(error)")
            return nil
        }
    }

}

extension Int {
    fileprivate func nonZeroOr(_ v: Int) -> Int { self == 0 ? v : self }
}
