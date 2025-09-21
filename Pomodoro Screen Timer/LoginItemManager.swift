//
//  LoginItemManager.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//
import ServiceManagement

enum LoginItemManager {
    /// MUST exactly match the helper target’s Bundle Identifier in its Info.plist
    static let helperID = "PomodoroScreenTimer.LoginItemHelper"

    static var isEnabled: Bool {
        if #available(macOS 13, *) {
            SMAppService.loginItem(identifier: helperID).status == .enabled
        } else {
            // for Monterey support, you can reflect a cached user pref here instead
            false
        }
    }

    static func set(enabled: Bool) throws {
        guard #available(macOS 13, *) else {
            // If supporting 12.x, use SMLoginItemSetEnabled(helperID as CFString, enabled) here.
            return
        }
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
            // Common benign cases:
            // - SMError.alreadyRegistered
            // - SMError.notFound
            throw error
        }
    }
}
