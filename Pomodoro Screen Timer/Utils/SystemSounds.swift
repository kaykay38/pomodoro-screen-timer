//
//  SystemSounds.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import AppKit
import AVFoundation

struct SystemSound {
    let name: String
    let displayName: String
    let isSystemSound: Bool
    
    static let systemSounds: [SystemSound] = [
        // iOS-style system sounds
        SystemSound(name: "Alarm", displayName: "Alarm", isSystemSound: true),
        SystemSound(name: "Anticipate", displayName: "Anticipate", isSystemSound: true),
        SystemSound(name: "Bell", displayName: "Bell", isSystemSound: true),
        SystemSound(name: "Bloom", displayName: "Bloom", isSystemSound: true),
        SystemSound(name: "Calypso", displayName: "Calypso", isSystemSound: true),
        SystemSound(name: "Chime", displayName: "Chime", isSystemSound: true),
        SystemSound(name: "Chord", displayName: "Chord", isSystemSound: true),
        SystemSound(name: "Crystal", displayName: "Crystal", isSystemSound: true),
        SystemSound(name: "Hillside", displayName: "Hillside", isSystemSound: true),
        SystemSound(name: "Illuminate", displayName: "Illuminate", isSystemSound: true),
        SystemSound(name: "Night Owl", displayName: "Night Owl", isSystemSound: true),
        SystemSound(name: "Opening", displayName: "Opening", isSystemSound: true),
        SystemSound(name: "Playtime", displayName: "Playtime", isSystemSound: true),
        SystemSound(name: "Presto", displayName: "Presto", isSystemSound: true),
        SystemSound(name: "Radar", displayName: "Radar", isSystemSound: true),
        SystemSound(name: "Reflection", displayName: "Reflection", isSystemSound: true),
        SystemSound(name: "Ripples", displayName: "Ripples", isSystemSound: true),
        SystemSound(name: "Sencha", displayName: "Sencha", isSystemSound: true),
        SystemSound(name: "Silk", displayName: "Silk", isSystemSound: true),
        SystemSound(name: "Slow Rise", displayName: "Slow Rise", isSystemSound: true),
        SystemSound(name: "Stargaze", displayName: "Stargaze", isSystemSound: true),
        SystemSound(name: "Summit", displayName: "Summit", isSystemSound: true),
        SystemSound(name: "Twinkle", displayName: "Twinkle", isSystemSound: true),
        SystemSound(name: "Uplift", displayName: "Uplift", isSystemSound: true),
        SystemSound(name: "Waves", displayName: "Waves", isSystemSound: true),
        
        // Classic macOS sounds
        SystemSound(name: "Basso", displayName: "Basso", isSystemSound: true),
        SystemSound(name: "Blow", displayName: "Blow", isSystemSound: true),
        SystemSound(name: "Bottle", displayName: "Bottle", isSystemSound: true),
        SystemSound(name: "Frog", displayName: "Frog", isSystemSound: true),
        SystemSound(name: "Funk", displayName: "Funk", isSystemSound: true),
        SystemSound(name: "Glass", displayName: "Glass", isSystemSound: true),
        SystemSound(name: "Hero", displayName: "Hero", isSystemSound: true),
        SystemSound(name: "Morse", displayName: "Morse", isSystemSound: true),
        SystemSound(name: "Ping", displayName: "Ping", isSystemSound: true),
        SystemSound(name: "Pop", displayName: "Pop", isSystemSound: true),
        SystemSound(name: "Purr", displayName: "Purr", isSystemSound: true),
        SystemSound(name: "Sosumi", displayName: "Sosumi", isSystemSound: true),
        SystemSound(name: "Submarine", displayName: "Submarine", isSystemSound: true),
        SystemSound(name: "Tink", displayName: "Tink", isSystemSound: true)
    ]
    
    static func isValidSystemSound(_ name: String) -> Bool {
        return systemSounds.contains { $0.name == name }
    }
}
