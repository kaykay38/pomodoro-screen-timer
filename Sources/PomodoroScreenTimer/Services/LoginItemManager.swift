//
//  LoginItemManager.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//
import ServiceManagement

enum LoginItemManager {
    // EXACT helper bundle id
    static let helperID = "PomodoroScreenTimer.Pomodoro-Screen-Timer.LoginItemHelper"

    static var isEnabled: Bool {
        guard #available(macOS 13, *) else { return false }
        return SMAppService.loginItem(identifier: helperID).status == .enabled
    }

    static func set(enabled: Bool) throws {
        guard #available(macOS 13, *) else { return }
        let svc = SMAppService.loginItem(identifier: helperID)
        do {
            if enabled {
                if svc.status != .enabled {
                    try svc.register()
                }
            } else {
                if svc.status != .notFound {
                    try svc.unregister()
                }
            }
        } catch {
            // Surface for logging
            NSLog("LoginItem register/unregister failed: \(String(describing: error))")
            throw error
        }
    }
}
