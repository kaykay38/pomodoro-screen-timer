//
//  AlarmHandle.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/18/25.
//
import Foundation

/// Unique token for a playing alarm; only the owner with this handle can stop it.
@MainActor
final class AlarmHandle: Equatable {
    let id = UUID()
    var onStop: (() -> Void)?
    static func == (l: AlarmHandle, r: AlarmHandle) -> Bool { l.id == r.id }
}
