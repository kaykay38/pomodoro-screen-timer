//
//  AlarmTestButton.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import Foundation
import SwiftUI

struct AlarmTestButton: View {
    var label: String = "Test Sound"

    // Keep these to help resolve the URL if the primary resolvedURL() fails
    var soundName: () -> String = { "" }
    var fileExtension: () -> String = { "" }
    var customPath: () -> String = { "" }
    var durationSeconds: () -> Double = { 0 }
    var resolvedURL: () -> URL? = { nil }

    @State private var handle: AlarmHandle?

    var body: some View {
        Button(handle == nil ? label : "Stop") {
            if let h = handle {
                AlarmPlayer.stop(handle: h)
                handle = nil
            } else {
                let dur = durationSeconds()
                let previewLimit = dur == 0 ? 5.0 : min(dur, 10.0)

                // 1. Resolve the best possible URL
                let urlToPlay: URL?

                if let url = resolvedURL() {
                    urlToPlay = url
                } else if !customPath().isEmpty {
                    urlToPlay = URL(fileURLWithPath: customPath())
                } else {
                    // Fallback to searching the bundle
                    urlToPlay = Bundle.main.url(
                        forResource: soundName(),
                        withExtension: fileExtension().isEmpty
                            ? "mp3" : fileExtension()
                    )
                }

                // 2. Play using the simplified AlarmPlayer
                if let url = urlToPlay {
                    let newHandle = AlarmPlayer.play(
                        url: url,
                        duration: previewLimit
                    )
                    handle = newHandle

                    // 3. Setup callback to flip button back to "Test" when audio ends
                    let id = newHandle.id
                    newHandle.onStop = {
                        // Ensure we only reset if it's the same playback session
                        if self.handle?.id == id {
                            self.handle = nil
                        }
                    }
                } else {
                    NSSound.beep()
                }
            }
        }
        .buttonStyle(.borderedProminent)
        .onDisappear {
            if let h = handle {
                AlarmPlayer.stop(handle: h)
                handle = nil
            }
        }
    }
}
