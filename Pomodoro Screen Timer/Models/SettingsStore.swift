//
//  SettingsStore.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import Foundation
import AppKit
import SwiftUI
import Combine
import ServiceManagement

enum BreakOverlayDurationMode: String {
    case fullBreak      // lasts for entire break
    case fixedSeconds   // lasts for N seconds, then auto-dismiss
}

final class SettingsStore: ObservableObject {
    // Durations & step
    @Published var defaultFocusMinutes: Int = UserDefaults.standard.integer(forKey: "defaultfocusMinutes").nonZeroOr(25) { didSet { UserDefaults.standard.set(defaultFocusMinutes, forKey: "defaultFocusMinutes") } }
    @Published var defaultBreakMinutes: Int = UserDefaults.standard.integer(forKey: "defaultBreakMinutes").nonZeroOr(5) { didSet { UserDefaults.standard.set(defaultBreakMinutes, forKey: "defaultBreakMinutes") } }
    @Published var longBreakMinutes: Int = UserDefaults.standard.integer(forKey: "longBreakMinutes").nonZeroOr(15) { didSet { UserDefaults.standard.set(longBreakMinutes, forKey: "longBreakMinutes") } }
    @Published var cyclesUntilLongBreak: Int = UserDefaults.standard.integer(forKey: "cyclesUntilLongBreak").nonZeroOr(4) { didSet { UserDefaults.standard.set(cyclesUntilLongBreak, forKey: "cyclesUntilLongBreak") } }
    @Published var minuteStep: Int = UserDefaults.standard.integer(forKey: "minuteStep").nonZeroOr(5) { didSet { UserDefaults.standard.set(minuteStep, forKey: "minuteStep") } }
    
    //    #if DEBUG
    //    @Published var devTreatMinutesAsSeconds: Bool = UserDefaults.standard.object(forKey: "devTreatMinutesAsSeconds") as? Bool ?? false {
    //        didSet { UserDefaults.standard.set(devTreatMinutesAsSeconds, forKey: "devTreatMinutesAsSeconds") }
    //    }
    //    #else
    @Published var devTreatMinutesAsSeconds: Bool = false
    //    #endif
    
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
    @Published var startTimerOnLaunch: Bool = UserDefaults.standard.bool(forKey: "startTimerOnLaunch") { didSet { UserDefaults.standard.set(startTimerOnLaunch, forKey: "startTimerOnLaunch") } }
    
    @Published var autoStartOnWatchedApps: Bool = UserDefaults.standard.bool(forKey: "autoStartOnWatchedApps") { didSet { UserDefaults.standard.set(autoStartOnWatchedApps, forKey: "autoStartOnWatchedApps") } }
    @Published var watchedBundleIDs: [String] = UserDefaults.standard.stringArray(forKey: "watchedBundleIDs") ?? ["org.mozilla.firefox", "com.microsoft.VSCode"] { didSet { UserDefaults.standard.set(watchedBundleIDs, forKey: "watchedBundleIDs") } }
    
    // Auto‑cycle
    @Published var autoCycleEnabled: Bool = UserDefaults.standard.object(forKey: "autoCycleEnabled") as? Bool ?? true { didSet { UserDefaults.standard.set(autoCycleEnabled, forKey: "autoCycleEnabled") } }
    
    // Break overlay
    @Published var showBreakOverlay: Bool = UserDefaults.standard.object(forKey: "showBreakOverlay") as? Bool ?? true {
        didSet { UserDefaults.standard.set(showBreakOverlay, forKey: "showBreakOverlay") }
    }
    @Published var breakOverlayColorHex: String = UserDefaults.standard.string(forKey: "breakOverlayColorHex") ?? "#1E90FF" {
        didSet { UserDefaults.standard.set(breakOverlayColorHex, forKey: "breakOverlayColorHex") }
    }
    @Published var breakOverlayImageName: String = UserDefaults.standard.string(forKey: "breakOverlayImageName") ?? "" {
        didSet { UserDefaults.standard.set(breakOverlayImageName, forKey: "breakOverlayImageName") }
    }
    // Custom break overlay image path
    @Published var customBreakImagePath: String = UserDefaults.standard.string(forKey: "customBreakImagePath") ?? "" {
        didSet { UserDefaults.standard.set(customBreakImagePath, forKey: "customBreakImagePath") }
    }
    @Published var breakOverlayDurationModeRaw: String = UserDefaults.standard.string(forKey: "overlayDurationModeRaw") ?? BreakOverlayDurationMode.fixedSeconds.rawValue {
        didSet { UserDefaults.standard.set(breakOverlayDurationModeRaw, forKey: "overlayDurationModeRaw") }
    }
    var breakOverlayDurationMode: BreakOverlayDurationMode {
        get { BreakOverlayDurationMode(rawValue: breakOverlayDurationModeRaw) ?? .fixedSeconds }
        set { breakOverlayDurationModeRaw = newValue.rawValue }
    }
    
    @Published var breakOverlaySeconds: Int = UserDefaults.standard.integer(forKey: "breakOverlaySeconds").nonZeroOr(4) {
        didSet { UserDefaults.standard.set(breakOverlaySeconds, forKey: "breakOverlaySeconds") }
    }
    
    // Focus reminder overlay (at end of break)
    @Published var showFocusOverlay: Bool =
    (UserDefaults.standard.object(forKey: "showFocusOverlay") as? Bool) ?? true {
        didSet { UserDefaults.standard.set(showFocusOverlay, forKey: "showFocusOverlay") }
    }
    
    @Published var focusOverlaySeconds: Int = UserDefaults.standard.integer(forKey: "focusOverlaySeconds").nonZeroOr(4) {
        didSet { UserDefaults.standard.set(focusOverlaySeconds, forKey: "focusOverlaySeconds") }
    }
    
    // Optional look & feel (reuse your break overlay color/image, or give these their own)
    @Published var focusOverlayColorHex: String =
    UserDefaults.standard.string(forKey: "focusOverlayColorHex") ?? "#111827" {
        didSet { UserDefaults.standard.set(focusOverlayColorHex, forKey: "focusOverlayColorHex") }
    }
    
    @Published var focusOverlayImageName: String =
    UserDefaults.standard.string(forKey: "focusOverlayImageName") ?? "" {
        didSet { UserDefaults.standard.set(focusOverlayImageName, forKey: "focusOverlayImageName") }
    }
    // Custom focus overlay image path
    @Published var customFocusImagePath: String = UserDefaults.standard.string(forKey: "customFocusImagePath") ?? "" {
        didSet { UserDefaults.standard.set(customFocusImagePath, forKey: "customFocusImagePath") }
    }
    
    
    // Break Alarm
    @Published var breakAlarmSoundName: String = UserDefaults.standard.string(forKey: "breakAlarmSoundName") ?? "Sosumi" {
        didSet { UserDefaults.standard.set(breakAlarmSoundName, forKey: "breakAlarmSoundName") }
    }
    @Published var breakAlarmFileExtension: String = UserDefaults.standard.string(forKey: "breakAlarmFileExtension") ?? "" {
        didSet { UserDefaults.standard.set(breakAlarmFileExtension, forKey: "breakAlarmFileExtension") }
    }
    @Published var customBreakSoundPath: String = UserDefaults.standard.string(forKey: "customBreakSoundPath") ?? "" {
        didSet { UserDefaults.standard.set(customBreakSoundPath, forKey: "customBreakSoundPath") }
    }
    
    // Focus Alarm
    @Published var focusAlarmSoundName: String = UserDefaults.standard.string(forKey: "focusAlarmSoundName") ?? "Bell" {
        didSet { UserDefaults.standard.set(focusAlarmSoundName, forKey: "focusAlarmSoundName") }
    }
    @Published var focusAlarmFileExtension: String = UserDefaults.standard.string(forKey: "focusAlarmFileExtension") ?? "" {
        didSet { UserDefaults.standard.set(focusAlarmFileExtension, forKey: "focusAlarmFileExtension") }
    }
    @Published var customFocusSoundPath: String = UserDefaults.standard.string(forKey: "customFocusSoundPath") ?? "" {
        didSet { UserDefaults.standard.set(customFocusSoundPath, forKey: "customFocusSoundPath") }
    }
    
    // Sound Duration (in seconds, 0 means full file length)
    @Published var alarmDurationSeconds: Double = UserDefaults.standard.object(forKey: "alarmDurationSeconds") as? Double ?? 3.0 {
        didSet { UserDefaults.standard.set(alarmDurationSeconds, forKey: "alarmDurationSeconds") }
    }
    
    // Legacy alarm settings for backward compatibility
    @Published var alarmSoundName: String = UserDefaults.standard.string(forKey: "alarmSoundName") ?? "Sosumi" {
        didSet { UserDefaults.standard.set(alarmSoundName, forKey: "alarmSoundName") }
    }
    @Published var alarmFileExtension: String = UserDefaults.standard.string(forKey: "alarmFileExtension") ?? "" {
        didSet { UserDefaults.standard.set(alarmFileExtension, forKey: "alarmFileExtension") }
    }
    @Published var customSoundPath: String = UserDefaults.standard.string(forKey: "customSoundPath") ?? "" {
        didSet { UserDefaults.standard.set(customSoundPath, forKey: "customSoundPath") }
    }
    // Persisted security-scoped bookmarks (Data is fine in UserDefaults)
    @Published var breakSoundBookmark: Data? = UserDefaults.standard.data(forKey: "breakSoundBookmark") {
        didSet { UserDefaults.standard.set(breakSoundBookmark, forKey: "breakSoundBookmark") }
    }
    @Published var focusSoundBookmark: Data? = UserDefaults.standard.data(forKey: "focusSoundBookmark") {
        didSet { UserDefaults.standard.set(focusSoundBookmark, forKey: "focusSoundBookmark") }
    }
    
    
    // MARK: - Bookmark helpers
    
    /// Call this right after user picks a break sound file in NSOpenPanel.
    func setCustomBreakSound(url: URL) {
        if let (bookmark, path) = Self.makeBookmark(for: url) {
            breakSoundBookmark = bookmark
            customBreakSoundPath = path                   // keep path for display/debug
        }
    }
    
    /// Call this right after user picks a focus sound file in NSOpenPanel.
    func setCustomFocusSound(url: URL) {
        if let (bookmark, path) = Self.makeBookmark(for: url) {
            focusSoundBookmark = bookmark
            customFocusSoundPath = path
        }
    }
    
    /// Use this when you need the actual Break URL to play.
    func resolvedBreakSoundURL() -> URL? {
        Self.resolveBookmark(breakSoundBookmark) ?? pathToURLIfPermitted(customBreakSoundPath)
    }
    
    /// Use this when you need the actual Focus URL to play.
    func resolvedFocusSoundURL() -> URL? {
        Self.resolveBookmark(focusSoundBookmark) ?? pathToURLIfPermitted(customFocusSoundPath)
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
            let data = try url.bookmarkData(options: .withSecurityScope,
                                            includingResourceValuesForKeys: nil,
                                            relativeTo: nil)
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
            let url = try URL(resolvingBookmarkData: data,
                              options: [.withSecurityScope],
                              relativeTo: nil,
                              bookmarkDataIsStale: &stale)
            _ = url.startAccessingSecurityScopedResource() // intentionally long-lived
            return url
        } catch {
            print("[BOOKMARK ERROR] resolve: \(error)")
            return nil
        }
    }
    
}

private extension Int { func nonZeroOr(_ v: Int) -> Int { self == 0 ? v : self } }
