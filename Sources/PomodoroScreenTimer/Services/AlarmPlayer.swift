//
//  AlarmPlayer.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import AVFoundation
import AppKit
import Foundation

@MainActor
enum AlarmPlayer {
    private static var audioPlayer: AVAudioPlayer?
    private static var durationTimer: Timer?
    private static var systemSound: NSSound?
    private static var currentHandle: AlarmHandle?

    // MARK: Public API

    /// Play from a file URL. Returns a handle for safe stopping.
    /// The primary play function called by TimerModel
    @discardableResult
    static func play(url: URL, duration: Double = 0) -> AlarmHandle {
        stop()

        let handle = AlarmHandle()
        currentHandle = handle

        // CRITICAL: Required for both System Ringtones and Security Scoped Bookmarks
        let canAccess = url.startAccessingSecurityScopedResource()

        if startAVPlayer(with: url, duration: duration, handle: handle) == false
        {
            print("[ALARM ERROR] Could not play URL: \(url.lastPathComponent)")
            NSSound.beep()
        }

        // We defer stopping access until the player is actually set up
        if canAccess { url.stopAccessingSecurityScopedResource() }

        return handle
    }

    /// Stop playback. If a handle is provided, only stops if it matches the currently playing one.
    static func stop(handle: AlarmHandle? = nil) {
        if let h = handle, h != currentHandle { return }  // ignore stale callers

        audioPlayer?.stop()
        audioPlayer = nil
        durationTimer?.invalidate()
        durationTimer = nil
        systemSound?.stop()
        systemSound = nil

        let finished = currentHandle  // capture before reset
        currentHandle = nil

        finished?.onStop?()  // emit
        finished?.onStop = nil
    }

    // for when voice is enabled
    static func fadeAndStop(
        duration: TimeInterval = 1.0,
        handle: AlarmHandle? = nil
    ) {
        if let h = handle, h != currentHandle { return }

        if let p = audioPlayer {
            p.setVolume(0, fadeDuration: duration)
            // Wait for fade to finish before fully stopping
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                stop(handle: handle)
            }
        } else {
            stop(handle: handle)
        }
    }

    // MARK: Internals

    @discardableResult
    private static func startAVPlayer(
        with url: URL,
        duration: Double,
        handle: AlarmHandle
    ) -> Bool {
        // 1. Start Accessing
        // This is the key for Sandbox. It returns true if it's a scoped resource.
        let isScoped = url.startAccessingSecurityScopedResource()

        // 2. Use defer to ensure we stop accessing when the function ends
        defer {
            if isScoped {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.volume = 1.0
            p.numberOfLoops = (duration > 0) ? -1 : 0
            p.prepareToPlay()

            guard p.play() else { return false }

            audioPlayer = p
            if duration > 0 { scheduleStop(after: duration, handle: handle) }
            return true
        } catch {
            print(
                "[ALARM ERROR] \(error.localizedDescription) for: \(url.lastPathComponent)"
            )
            return false
        }
    }

    private static func scheduleStop(after seconds: Double, handle: AlarmHandle)
    {
        let t = Timer(timeInterval: seconds, repeats: false) { _ in
            // only stop if this handle is still current
            // Timer's closure is nonisolated; hop back to the main actor.
            Task { @MainActor in
                stop(handle: handle)
            }
        }
        durationTimer?.invalidate()
        durationTimer = t
        RunLoop.main.add(t, forMode: .common)
    }
}

//// Optional convenience wrappers (unchanged call sites, but now return a handle)
//extension AlarmPlayer {
//    @discardableResult
//    static func playAlarm(
//        soundName: String,
//        fileExtension: String,
//        customSoundPath: String,
//        duration: Double
//    ) -> AlarmHandle {
//        play(
//            soundName: soundName,
//            fileExtension: fileExtension,
//            customSoundPath: customSoundPath,
//            duration: duration
//        )
//    }
//}
