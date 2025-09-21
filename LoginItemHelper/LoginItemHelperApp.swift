//
//  LoginItemHelperApp.swift
//  LoginItemHelper
//
//  Created by Mia on 9/16/25.
//

import Cocoa

@main
final class LoginItemHelperApp: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ note: Notification) {
        // 1) Read the main app bundle id from Info (Option A or B)
        let mainID = (Bundle.main.object(forInfoDictionaryKey: "MainAppBundleIdentifier") as? String)
                     ?? "PomodoroScreenTimer" // fallback if you prefer

        // 2) Don’t relaunch if already running
        if !NSRunningApplication.runningApplications(withBundleIdentifier: mainID).isEmpty {
            NSApp.terminate(nil); return
        }

        // 3) Launch main app quietly then quit
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: mainID) else {
            NSLog("[LoginItemHelper] Could not resolve main app URL for \(mainID)")
            NSApp.terminate(nil); return
        }
        let cfg = NSWorkspace.OpenConfiguration()
        cfg.activates = false
        cfg.createsNewApplicationInstance = false
        NSWorkspace.shared.openApplication(at: appURL, configuration: cfg) { _, _ in
            NSApp.terminate(nil)
        }
    }
}
