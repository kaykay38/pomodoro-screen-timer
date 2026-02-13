//
//  OverlayController.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/18/25.
//

import SwiftUI
import AppKit

@MainActor
final class OverlayController {
    
    static let shared = OverlayController()

    private var windows: [NSWindow] = []
    private var hosts: [NSHostingController<OverlayView>] = []

    private var countdownTimer: Timer?
    private var remainingSeconds: Int = 0

    private var onPrimary: (() -> Void)?
    private var onDismiss: (() -> Void)?

    private var alarmHandle: AlarmHandle?

    func show(_ config: OverlayConfig,
              alarmHandle: AlarmHandle,
              onPrimary: (() -> Void)? = nil,
              onDismiss:  (() -> Void)? = nil) {

        if !hosts.isEmpty {
            for host in hosts {
                host.rootView = OverlayView(
                    config: config,
                    onClose:   { [weak self] in self?.dismiss() },
                    onPrimary: { [weak self] in self?.firePrimaryAndDismiss() }
                )
            }
            self.alarmHandle = alarmHandle
            self.onPrimary  = onPrimary
            self.onDismiss  = onDismiss
            restartCountdownIfNeeded(config.durationSeconds)
            return
        }

        for screen in NSScreen.screens {
            let view = OverlayView(
                config: config,
                onClose:   { [weak self] in self?.dismiss() },
                onPrimary: { [weak self] in self?.firePrimaryAndDismiss() }
            )

            let host = NSHostingController(rootView: view)
            let win  = OverlayNSWindow(contentViewController: host)
            
            win.styleMask = [.borderless]
            win.isOpaque = true
            win.hasShadow = false
            win.ignoresMouseEvents = false
            win.isMovable = false
            
            win.level = .screenSaver
            win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            
            win.backgroundColor = .black
            win.setFrame(screen.frame, display: true)
            
            
            win.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)

            windows.append(win)
            hosts.append(host)
        }

        self.alarmHandle = alarmHandle
        self.onPrimary   = onPrimary
        self.onDismiss   = onDismiss

        restartCountdownIfNeeded(config.durationSeconds)
    }

    func dismiss(fireOnDismiss: Bool = false) {
        countdownTimer?.invalidate(); countdownTimer = nil
        let hadWindows = !windows.isEmpty

        for window in windows { window.orderOut(nil) }
        windows.removeAll(); hosts.removeAll()

        if fireOnDismiss { onDismiss?() }
        onPrimary = nil; onDismiss = nil

        // Only stop if this overlay was actually visible and it owns the alarm
        if hadWindows, let h = alarmHandle {
            AlarmPlayer.stop(handle: h)
        }
        alarmHandle = nil
    }

    private func firePrimaryAndDismiss() {
        let action = onPrimary
        if let h = alarmHandle { AlarmPlayer.stop(handle: h) } // user explicitly acted
        dismiss()
        action?()
    }

    private func restartCountdownIfNeeded(_ duration: Int?) {
        countdownTimer?.invalidate()
        guard let secs = duration, secs > 0 else { return }
        remainingSeconds = secs
        countdownTimer = Timer.scheduledTimer(timeInterval: 1,
                                              target: self,
                                              selector: #selector(tick),
                                              userInfo: nil,
                                              repeats: true)
        if let t = countdownTimer { RunLoop.main.add(t, forMode: .common) }
        NotificationCenter.default.post(name: .overlayTick, object: nil, userInfo: ["remaining": remainingSeconds])
    }

    @objc private func tick() {
        remainingSeconds -= 1
        NotificationCenter.default.post(name: .overlayTick, object: nil, userInfo: ["remaining": remainingSeconds])
        if remainingSeconds <= 0 {
            countdownTimer?.invalidate(); countdownTimer = nil
            dismiss(fireOnDismiss: true)
        }
    }
}
