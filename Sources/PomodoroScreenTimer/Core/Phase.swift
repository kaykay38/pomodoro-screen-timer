//
//  Phase.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/17/25.
//

import Foundation
import SwiftUI

/// Represents the different phases of a Pomodoro timer session
enum Phase: String, CaseIterable {
    case focus = "focus"
    case shortBreak = "shortBreak" 
    case longBreak = "longBreak"
    
    /// Human-readable display name for the phase
    var displayName: String {
        switch self {
        case .focus: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
    
    /// Whether this phase is a break phase
    var isBreak: Bool {
        switch self {
        case .focus: return false
        case .shortBreak, .longBreak: return true
        }
    }
    
    /// Whether this phase is a focus phase
    var isFocus: Bool {
        return self == .focus
    }
}

/// Color coordination for different phases
extension Phase {
    var shortName: String {
        switch self {
        case .focus: return "F"
        case .shortBreak: return "B"
        case .longBreak: return "L"
        }
    }
    
    /// SwiftUI Color for this phase
    var color: Color {
        switch self {
        case .focus: return .green
        case .shortBreak, .longBreak: return .red
        }
    }
    
    var nsColor: NSColor {
        switch self {
        case .focus:      return .systemGreen
        case .shortBreak, .longBreak: return .systemRed
        }
    }
}
