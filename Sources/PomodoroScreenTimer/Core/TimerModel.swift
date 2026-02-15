//
//  TimerModel.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import AVFoundation
import AppKit
import Combine
import Foundation
import SwiftUI
import UserNotifications

@MainActor
final class TimerModel: ObservableObject {
    @Published var totalSeconds: Int
    @Published var remaining: Int
    @Published var isRunning = false
    @Published var phase: Phase = .focus
    @Published var completedFocusCount: Int = 0
    @Published var completedShortBreakCount: Int = 0
    @Published var completedLongBreakCount: Int = 0

    let settings: SettingsStore
    private var timer: DispatchSourceTimer?

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
    }

    func setMinutes(_ minutes: Int) {
        //        totalSeconds = max(1, minutes) * 60
        let base = max(1, minutes) * 60  // DEBUG only
        totalSeconds = adjustSeconds(base)  // DEBUG only
        if !isRunning { remaining = totalSeconds }
    }

    func start() {
        stop()
        if remaining <= 0 { remaining = totalSeconds }
        isRunning = true
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(
            deadline: .now(),
            repeating: .seconds(1),
            leeway: .milliseconds(200)
        )
        t.setEventHandler { [weak self] in self?.tick() }
        t.resume()
        timer = t
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
        // dismiss any active overlays when manually resetting
        OverlayController.shared.dismiss()
    }

    // Convenience
    func resetToFocus() { reset(for: .focus) }
    func resetToBreak() { reset(for: .shortBreak) }

    // MARK: Private Timer logic
    private func tick() {
        guard remaining > 0 else {
            finished()
            return
        }
        remaining -= 1
    }

    private func finished() {
        stop()  // stop the tick FIRST
        OverlayController.shared.dismiss()  // Stop outgoing overlay

        // Determine outgoing and next phase
        let outgoingPhase = phase
        let nextPhase = calculateNextPhase(from: outgoingPhase)

        let voiceEnabled =
            (nextPhase == .focus)
            ? settings.focusMessageVoiceEnabled
            : settings.breakMessageVoiceEnabled

        // set the duration to 2 seconds then fadeout stop if voiceEnabled
        let duration = voiceEnabled ? 2.0 : settings.alarmDurationSeconds
        let alarmHandle = playAlarm(for: nextPhase, overrideDuration: duration)
        if voiceEnabled {
            // After 2 seconds of full volume, start a 1-second fade
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                AlarmPlayer.fadeAndStop(duration: 1.0, handle: alarmHandle)
            }
            // Speak exactly when the alarm is fully faded (3s total)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.speakMessage(for: nextPhase)
            }
        }

        // 3. Present Overlay
        presentOverlay(nextPhase: nextPhase, alarmHandle: alarmHandle) {
            [weak self] in
            self?.start()
        }

        // 4. Update focus and break counts
        if outgoingPhase == .focus {
            completedFocusCount += 1
        } else if outgoingPhase == .shortBreak {
            completedShortBreakCount += 1
        } else {
            completedLongBreakCount += 1
        }

        // 5. Update the global phase to the nextPhase
        phase = nextPhase
        totalSeconds = seconds(for: phase)  // update the new phase seconds
        remaining = totalSeconds  // set remaining to new phase seconds

    }

    private func calculateNextPhase(from outgoingPhase: Phase) -> Phase {
        // If we just finished a break, we always go back to focus
        guard outgoingPhase == .focus else { return .focus }

        let nextFocusCount = completedFocusCount + 1
        return (nextFocusCount % max(1, settings.cyclesUntilLongBreak) == 0)
            ? .longBreak
            : .shortBreak
    }

    // MARK: Side Effects (Audio, UI, Notifications)

    private func playAlarm(for nextPhase: Phase, overrideDuration: Double? = nil) -> AlarmHandle {
        let isFocus = (nextPhase == .focus)
        let duration = overrideDuration ?? settings.alarmDurationSeconds
        
        // 1. Resolve the target URL
        var targetURL: URL?
        
        if isFocus {
            if settings.focusAlarmCustomSoundEnabled {
                targetURL = settings.resolvedFocusSoundURL()
            } else {
                targetURL = SystemSounds.systemSounds.first(where: { $0.name == settings.focusAlarmSoundName })?.url
            }
        } else {
            if settings.breakAlarmCustomSoundEnabled {
                targetURL = settings.resolvedBreakSoundURL()
            } else {
                targetURL = SystemSounds.systemSounds.first(where: { $0.name == settings.breakAlarmSoundName })?.url
            }
        }

        // 2. The "Emergency" Fallback
        // If targetURL is still nil (e.g., a file was deleted), find a bundled resource or a basic system sound
        let finalURL = targetURL ?? Bundle.main.url(forResource: isFocus ? "Bell" : "Sosumi", withExtension: "mp3")
        
        // 3. Play via the simplified AlarmPlayer
        if let url = finalURL {
            return AlarmPlayer.play(url: url, duration: duration)
        } else {
            // If we reach here, even the bundled sound is missing
            NSSound.beep()
            return AlarmHandle()
        }
    }
    
    private func speakMessage(for nextPhase: Phase) {
        let voiceEnabled =
            (nextPhase == .focus)
            ? settings.focusMessageVoiceEnabled
            : settings.breakMessageVoiceEnabled  // 1. Check if overlay is enabled in settings
        guard voiceEnabled else { return }

        let message: String
        let selectedVoiceID = (nextPhase == .focus) ? settings.focusMessageVoiceID : settings.breakMessageVoiceID
        
        switch nextPhase {
        case .focus:
            message = settings.focusMessage
        case .longBreak:
            message = settings.lBreakMessage
        default:
            message = settings.sBreakMessage
        }

        SpeechSynthesizer.shared.speak(message, voiceID: selectedVoiceID)
    }

    private func presentOverlay(
        nextPhase: Phase,
        alarmHandle: AlarmHandle,
        onStart: @escaping () -> Void
    ) {
        let isFocus = (nextPhase == .focus)

        // 1. Check if overlay is enabled in settings
        if isFocus && !settings.focusOverlayEnabled {
            onStart()
            return
        }
        if !isFocus && !settings.breakOverlayEnabled {
            onStart()
            return
        }

        // 2. Resolve Image
        let customPath =
            isFocus
            ? settings.focusOverlayCustomImagePath
            : settings.breakOverlayCustomImagePath
        let defaultName =
            isFocus
            ? settings.focusOverlayImageName : settings.breakOverlayImageName
        let finalImage =
            !customPath.isEmpty
            ? customPath : (!defaultName.isEmpty ? defaultName : nil)

        // 3. Configure Text & Actions based on AutoCycle setting
        let message: String
        let duration: Int?
        let primaryButton: String?
        let counterLabel: String?
        let showDismiss: Bool

        if settings.autoCycleEnabled {
            // Auto-cycle logic
            if isFocus {
                message = settings.focusMessage
                duration = max(0, settings.focusOverlaySeconds)
                primaryButton = "Start Now"
                counterLabel = "Starting in"
                showDismiss = false
            } else {
                message =
                    (nextPhase == .longBreak)
                    ? settings.lBreakMessage : settings.sBreakMessage
                duration =
                    (settings.breakOverlayDurationMode == .fixedSeconds)
                    ? settings.breakOverlaySeconds : nil
                primaryButton = nil
                counterLabel = (duration != nil) ? "Closing in" : nil
                showDismiss = settings.breakOverlayShowDismissButton
            }
        } else {
            // Manual mode logic
            message =
                isFocus
                ? settings.focusMessage
                : (nextPhase == .longBreak
                    ? settings.lBreakMessage : settings.sBreakMessage)
            duration = nil
            primaryButton = isFocus ? "Start Focus" : nil
            counterLabel = nil
            showDismiss =
                isFocus ? true : settings.breakOverlayShowDismissButton
        }

        // 4. Construct and Show
        // Note: Assuming 'OverlayProps' or the type expected by .init matches your OverlayController
        OverlayController.shared.show(
            .init(
                customImageEnabled: isFocus
                    ? settings.focusOverlayCustomImageEnabled
                    : settings.breakOverlayCustomImageEnabled,
                colorHex: isFocus
                    ? settings.focusOverlayColorHex
                    : settings.breakOverlayColorHex,
                imageName: finalImage,
                message: message,
                durationSeconds: duration,
                primaryButtonTitle: primaryButton,
                counterLabel: counterLabel,
                showDismissButton: showDismiss
            ),
            alarmHandle: alarmHandle,
            onPrimary: onStart,
            onDismiss: onStart
        )

        // Handle the specific auto-cycle break delay if duration is set
        // This ensures the audio starts clearly before the next timer ticks
        if settings.autoCycleEnabled, !isFocus, duration != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                onStart()
            }
        }
    }

    // test helper, set run time to seconds instead of minutes
    private func adjustSeconds(_ seconds: Int) -> Int {
        if settings.devTreatMinutesAsSeconds {
            // 1 minute typed -> 1 second of run time
            return max(1, Int((Double(seconds) / 60.0).rounded()))
        } else {
            return seconds
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
        case .focus: base = settings.defaultFocusMinutes * 60
        case .shortBreak: base = settings.defaultBreakMinutes * 60
        case .longBreak: base = settings.longBreakMinutes * 60
        }
        return adjustSeconds(base)
        // DEBUG only
    }

    func menuBarTitle() -> String {
        let m = remaining / 60
        let s = remaining % 60
        let title = String(format: "%02d:%02d", m, s)
        return title
    }

}
