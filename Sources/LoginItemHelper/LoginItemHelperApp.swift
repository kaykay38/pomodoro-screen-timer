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
        guard
            let mainID = Bundle.main.object(forInfoDictionaryKey: "MainAppBundleIdentifier") as? String
        else {
            NSLog("[LoginItemHelper] Missing MainAppBundleIdentifier in Info.plist")
            NSApp.terminate(nil); return
        }

        if !NSRunningApplication.runningApplications(withBundleIdentifier: mainID).isEmpty {
            NSApp.terminate(nil); return
        }

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
