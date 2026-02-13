//
//  VoicePicker.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/13/26.
//

import AVFoundation
import SwiftUI

struct VoicePicker: View {
    let title: String
    @Binding var selectedID: String?
    
    // Fetch and sort voices once
    private let availableVoices: [AVSpeechSynthesisVoice] = {
        let currentLang = AVSpeechSynthesisVoice.currentLanguageCode()
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.starts(with: currentLang.prefix(2)) }
            .sorted { $0.name < $1.name }
    }()

    var body: some View {
        Picker(title, selection: $selectedID) {
            Text("System Default").tag(String?.none)
            Divider()
            ForEach(availableVoices, id: \.identifier) { voice in
                HStack {
                    Text(voice.name)
                    if voice.quality == .premium || voice.quality == .enhanced {
                        Text("HD").font(.caption2).padding(2).background(.quaternary).cornerRadius(4)
                    }
                }
                .tag(String?.some(voice.identifier))
            }
        }
    }
}
