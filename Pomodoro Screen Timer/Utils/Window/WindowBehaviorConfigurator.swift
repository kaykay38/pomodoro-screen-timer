//
//  WindowBehaviorConfigurator.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 1/13/26.
//

import SwiftUI
import AppKit

struct WindowBehaviorConfigurator: NSViewRepresentable {
    enum Behavior {
        case normal
        case floating
    }

    let behavior: Behavior

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            applyBehavior(to: window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    private func applyBehavior(to window: NSWindow) {
        switch behavior {
        case .normal:
            window.level = .normal

        case .floating:
            window.level = .floating
            window.styleMask.insert(.utilityWindow)
            window.hidesOnDeactivate = false
            window.isReleasedWhenClosed = false
            window.collectionBehavior = [
                .canJoinAllSpaces,
                .fullScreenAuxiliary
            ]
        }
    }
}
