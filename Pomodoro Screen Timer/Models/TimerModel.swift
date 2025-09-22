//
//  TimerModel.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import Foundation
import AppKit
import Combine
import AVFoundation
import UserNotifications
import SwiftUI

@MainActor
final class TimerModel: ObservableObject {
    @Published var totalSeconds: Int
    @Published var remaining: Int
    @Published var isRunning = false
    @Published var phase: Phase = .focus
    @Published var completedFocusCount: Int = 0
    
    let settings: SettingsStore
    private var timer: DispatchSourceTimer?
    
    // test helper
    private func scaled(_ seconds: Int) -> Int {
        if settings.devTreatMinutesAsSeconds {
            // 1 minute typed -> 1 second of runtime
            return max(1, Int((Double(seconds) / 60.0).rounded()))
        } else {
            return seconds
        }
    }
    
    init(settings: SettingsStore) {
        self.settings = settings
        
        // DEBUG start
        var initial = settings.defaultFocusMinutes * 60
        if settings.devTreatMinutesAsSeconds {
            // 1 minute typed -> 1 second of runtime
            initial = max(1, Int((Double(initial) / 60.0).rounded()))
        }
        // DEBUG end
        
        self.totalSeconds = initial
        self.remaining = initial
        print("[TIMER INIT] Initial remaining: \(remaining), totalSeconds: \(totalSeconds), phase: \(phase.rawValue)")
        requestNotificationPermission()
        AppLifecycle.shared.startObserving(settings: settings, model: self)
    }
    
    func setMinutes(_ minutes: Int) {
        //        totalSeconds = max(1, minutes) * 60
        let base = max(1, minutes) * 60 // DEBUG only
        totalSeconds = scaled(base) // DEBUG only
        if !isRunning { remaining = totalSeconds }
    }
    
    func start() {
        stop()
        if remaining <= 0 { remaining = totalSeconds }
        isRunning = true
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(200))
        t.setEventHandler { [weak self] in self?.tick() }
        t.resume(); timer = t
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
    }
    
    func toggleStartStop() {
        isRunning ? stop() : start()
    }
    
    func reset(for phase: Phase) {
        self.phase = phase
        totalSeconds = seconds(for: phase)
        remaining = totalSeconds
        stop()
        // unified overlay only
        OverlayController.shared.dismiss()
    }
    
    // Convenience
    func resetToFocus() { reset(for: .focus) }
    func resetToBreak()  { reset(for: .shortBreak) }
    
    private func tick() {
        guard remaining > 0 else { finished(); return }
        remaining -= 1
    }
    
    private func finished() {
        stop() // stop the tick FIRST
        
        // Determine outgoing and next phase
        let outgoing = phase
        let next: Phase = {
            if outgoing == .focus {
                let c = completedFocusCount + 1
                return (c % max(1, settings.cyclesUntilLongBreak) == 0) ? .longBreak : .shortBreak
            } else {
                return .focus
            }
        }()
        
        // 0) Stop outgoing overlay first (will stop the OLD alarm if visible)
        OverlayController.shared.dismiss()
        
        // 1) Start NEW phase alarm and capture its handle
        let handle: AlarmHandle
        if next == .focus {
            if let url = settings.resolvedFocusSoundURL() {
                handle = AlarmPlayer.play(url: url, duration: settings.alarmDurationSeconds)
            } else {
                handle = AlarmPlayer.playAlarm(
                    soundName: settings.focusAlarmSoundName,
                    fileExtension: settings.focusAlarmFileExtension,
                    customSoundPath: settings.customFocusSoundPath,
                    duration: settings.alarmDurationSeconds
                )
            }
        } else {
            if let url = settings.resolvedBreakSoundURL() {
                handle = AlarmPlayer.play(url: url, duration: settings.alarmDurationSeconds)
            } else {
                handle = AlarmPlayer.playAlarm(
                    soundName: settings.breakAlarmSoundName,
                    fileExtension: settings.breakAlarmFileExtension,
                    customSoundPath: settings.customBreakSoundPath,
                    duration: settings.alarmDurationSeconds
                )
            }
        }
        
        // 2) Post system notification
        postLocalNotification()
        
        // 3) Switch phase + reset counters
        if outgoing == .focus { completedFocusCount += 1 }
        phase = next
        totalSeconds = seconds(for: phase)
        remaining = totalSeconds
        
        // 4) UI / overlays (autoCycle + manual, unified overlay, pass handle)
        if settings.autoCycleEnabled {
            if next == .shortBreak || next == .longBreak {
                // entering a break
                if settings.showBreakOverlay {
                    let imageName = !settings.customBreakImagePath.isEmpty ? settings.customBreakImagePath :
                    (!settings.breakOverlayImageName.isEmpty ? settings.breakOverlayImageName : nil)
                    let durationForUI: Int? =
                    (settings.breakOverlayDurationMode == .fixedSeconds) ? settings.breakOverlaySeconds : nil
                    
                    OverlayController.shared.show(
                        .init(
                            colorHex: settings.breakOverlayColorHex,
                            imageName: imageName,
                            title: "Break time",
                            subtitle: next == .longBreak ? "Take a longer rest" : "Step away for a few minutes",
                            durationSeconds: durationForUI,
                            primaryButtonTitle: nil,
                            counterText: durationForUI == nil ? nil : "Closing in"
                        ),
                        handle: handle
                    )
                    
                    // tiny defer to keep audio clearly started
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                        self.start()
                    }
                } else {
                    start()
                }
            } else {
                // entering focus
                if settings.showFocusOverlay {
                    let duration = max(0, settings.focusOverlaySeconds)
                    let imageName = !settings.customFocusImagePath.isEmpty ? settings.customFocusImagePath :
                    (!settings.focusOverlayImageName.isEmpty ? settings.focusOverlayImageName : nil)
                    
                    OverlayController.shared.show(
                        .init(
                            colorHex: settings.focusOverlayColorHex,
                            imageName: imageName,
                            title: "Ready to focus?",
                            subtitle: "Settle in — we'll start when this closes, or press Start Now.",
                            durationSeconds: duration,
                            primaryButtonTitle: "Start Now",
                            counterText: "Starting in"
                        ),
                        handle: handle,
                        onPrimary: { [weak self] in self?.start() },
                        onDismiss: { [weak self] in self?.start() }
                    )
                } else {
                    start()
                }
            }
        } else {
            // Manual mode
            if next == .shortBreak || next == .longBreak {
                if settings.showBreakOverlay {
                    let imageName = !settings.customBreakImagePath.isEmpty ? settings.customBreakImagePath :
                    (!settings.breakOverlayImageName.isEmpty ? settings.breakOverlayImageName : nil)
                    OverlayController.shared.show(
                        .init(
                            colorHex: settings.breakOverlayColorHex,
                            imageName: imageName,
                            title: "Break time",
                            subtitle: next == .longBreak ? "Take a longer rest" : "Step away for a few minutes",
                            durationSeconds: nil,
                            primaryButtonTitle: "Start Break",
                            counterText: nil
                        ),
                        handle: handle,
                        onPrimary: { [weak self] in self?.start() }
                    )
                }
            } else {
                let imageName = !settings.customFocusImagePath.isEmpty ? settings.customFocusImagePath :
                (!settings.focusOverlayImageName.isEmpty ? settings.focusOverlayImageName : nil)
                OverlayController.shared.show(
                    .init(
                        colorHex: settings.focusOverlayColorHex,
                        imageName: imageName,
                        title: "Ready to focus?",
                        subtitle: "Press Start Now when you're ready to begin the focus session.",
                        durationSeconds: nil,
                        primaryButtonTitle: "Start Focus",
                        counterText: nil
                    ),
                    handle: handle,
                    onPrimary: { [weak self] in self?.start() }
                )
            }
        }
    }
    
    private func seconds(for phase: Phase) -> Int {
        //        switch phase {
        //        case .focus:      return settings.defaultFocusMinutes * 60
        //        case .shortBreak: return settings.defaultBreakMinutes * 60
        //        case .longBreak:  return settings.longBreakMinutes  * 60
        //        }
        // DEBUG only
        let base: Int
        switch phase {
        case .focus:      base = settings.defaultFocusMinutes * 60
        case .shortBreak: base = settings.defaultBreakMinutes * 60
        case .longBreak:  base = settings.longBreakMinutes  * 60
        }
        return scaled(base)
        // DEBUG only
    }
    
    
    
    private func postLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = phase == .focus ? "Focus complete" : "Break complete"
        content.body  = phase == .focus ? "Time for a break" : "Back to focus"
        content.sound = .default
        let req = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        UNUserNotificationCenter.current().add(req)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    func menuBarTitle() -> String {
        let m = remaining / 60, s = remaining % 60
        let title = String(format: "%02d:%02d", m, s)
        return title
    }
    
}
