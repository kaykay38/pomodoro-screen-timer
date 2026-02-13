//
//  OverlayNSWindow.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import AppKit

// This subclass allows a borderless window to receive keyboard shortcuts
class OverlayNSWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
}
