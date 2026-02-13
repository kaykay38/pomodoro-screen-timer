//
//  SpeechSynthesis.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import AVFoundation
import Combine

final class SpeechSynthesizer: NSObject {
    // Use the 'shared' singleton pattern
    static let shared = SpeechSynthesizer()

    private let synthesizer = AVSpeechSynthesizer()

    // Publish the speaking state so SwiftUI can react to it
    @Published var isSpeaking: Bool = false

    private override init() {
        super.init()
        synthesizer.delegate = self  // We need this to reset isSpeaking to false
    }

    func speak(_ text: String, voiceID: String? = nil) {
        let utterance = AVSpeechUtterance(string: text)

        // Pick a voice
        if let voiceID = voiceID,
            let voice = AVSpeechSynthesisVoice(identifier: voiceID)
        {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.1

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}

// Updates the isSpeaking state automatically
extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        isSpeaking = false
    }
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        isSpeaking = false
    }
}
