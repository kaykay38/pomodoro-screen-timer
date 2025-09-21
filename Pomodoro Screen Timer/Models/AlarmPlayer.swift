//
//  AlarmPlayer.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import AppKit
import AVFoundation
import Foundation

@MainActor
enum AlarmPlayer {
    private static var audioPlayer: AVAudioPlayer?
    private static var durationTimer: Timer?
    private static var systemSound: NSSound?
    private static var currentHandle: AlarmHandle?

    // MARK: Public API

    /// Play from a file URL. Returns a handle for safe stopping.
    @discardableResult
    static func play(url: URL, duration: Double = 0) -> AlarmHandle {
        stop() // cancel any prior playback/timer
        let handle = AlarmHandle()
        if startAVPlayer(with: url, duration: duration, handle: handle) == false {
            NSSound.beep()
        }
        print("[ALARM INFO] started playing from \(url.path)")
        return handle
    }

    /// Resolve & play using custom path or bundled name/ext. Returns a handle.
    @discardableResult
    static func play(
        soundName: String,
        fileExtension: String = "",
        customSoundPath: String = "",
        duration: Double = 0
    ) -> AlarmHandle {
        stop()
        let handle = AlarmHandle()

        // Prefer custom file
        if !customSoundPath.isEmpty {
            let url = URL(fileURLWithPath: customSoundPath)
            if FileManager.default.fileExists(atPath: url.path) {
                if startAVPlayer(with: url, duration: duration, handle: handle) { return handle }
            } else {
                print("[ALARM ERROR] custom path missing @ \(url.path)")
            }
        }

        // Bundled with explicit extension
        if !fileExtension.trimmingCharacters(in: .whitespaces).isEmpty,
           let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension),
           startAVPlayer(with: url, duration: duration, handle: handle) {
            return handle
        }

        // Try common bundle extensions if ext blank
        if fileExtension.trimmingCharacters(in: .whitespaces).isEmpty {
            for ext in ["mp3","wav","aiff","m4a","caf"] {
                if let url = Bundle.main.url(forResource: soundName, withExtension: ext),
                   startAVPlayer(with: url, duration: duration, handle: handle) {
                    return handle
                }
            }
        }

        // System sound fallback (short)
        systemSound = NSSound(named: NSSound.Name(soundName))
        if let s = systemSound {
            s.volume = 1.0
            let ok = s.play()
            print("[ALARM \(ok ? "OK" : "FAIL")] NSSound '\(soundName)'")
            currentHandle = handle
            if duration > 0 { scheduleStop(after: duration, handle: handle) }
            return handle
        }

        NSSound.beep()
        return handle
    }

    /// Stop playback. If a handle is provided, only stops if it matches the currently playing one.
    static func stop(handle: AlarmHandle? = nil) {
        if let h = handle, h != currentHandle { return } // ignore stale callers
        
        audioPlayer?.stop(); audioPlayer = nil
        durationTimer?.invalidate(); durationTimer = nil
        systemSound?.stop(); systemSound = nil
        
        let finished = currentHandle // capture before reset
        currentHandle = nil
        
        finished?.onStop?() // emit
        finished?.onStop = nil
    }

    // MARK: - Internals

    @discardableResult
    private static func startAVPlayer(with url: URL, duration: Double, handle: AlarmHandle) -> Bool {
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.volume = 1.0
            p.enableRate = true
            p.prepareToPlay()
            p.currentTime = 0

            if duration <= 0 {
                p.numberOfLoops = 0            // play once (set -1 if you want infinite by default)
            } else {
                p.numberOfLoops = -1           // loop until we stop after `duration`
            }

            guard p.play() else {
                print("[ALARM ERROR] AVAudioPlayer failed to play() url=\(url.lastPathComponent)")
                audioPlayer = nil
                currentHandle = nil
                return false
            }

            audioPlayer = p
            currentHandle = handle
            
            if duration > 0 { scheduleStop(after: duration, handle: handle) }
            return true
        } catch {
            print("[ALARM ERROR] AVAudioPlayer init failed: \(error) @ \(url.path)")
            return false
        }
    }

    private static func scheduleStop(after seconds: Double, handle: AlarmHandle) {
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

// Optional convenience wrappers (unchanged call sites, but now return a handle)
extension AlarmPlayer {
    @discardableResult
    static func playAlarm(soundName: String, fileExtension: String, customSoundPath: String, duration: Double) -> AlarmHandle {
        play(soundName: soundName, fileExtension: fileExtension, customSoundPath: customSoundPath, duration: duration)
    }
}
