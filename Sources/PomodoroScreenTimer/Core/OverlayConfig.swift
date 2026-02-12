//
//  OverlayConfig.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/10/26.
//

import Foundation

struct OverlayConfig {
    let colorHex: String
    let imageName: String?
    let message: String
    let durationSeconds: Int?        // nil = no countdown/auto-dismiss
    let primaryButtonTitle: String?  // e.g. "Start Now"
    let counterLabel: String?         // e.g. "Closing in" / "Starting in"
    let showDismissButton: Bool
}
