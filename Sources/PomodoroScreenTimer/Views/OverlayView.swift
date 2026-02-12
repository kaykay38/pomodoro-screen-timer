//
//  OverlayView.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/18/25.
//

import AppKit
import SwiftUI

extension Notification.Name {
    static let overlayTick = Notification.Name("UnifiedOverlayTick")
}

struct OverlayView: View {
    let config: OverlayConfig
    var onClose: () -> Void
    var onPrimary: () -> Void
    @State private var remaining: Int?
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        ZStack {
            backgroundView.ignoresSafeArea()
            VStack(spacing: 16) {
                Text(config.message)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                if let r = remaining, let label = config.counterLabel {
                    Text("\(label) \(r)s")
                        .font(.headline.monospacedDigit())
                        .padding(.top, 6)
                }
                if config.showDismissButton {
                    HStack(spacing: 16) {
                        Button("Dismiss") { onClose() }
                            .keyboardShortcut(.escape, modifiers: [])
                            .buttonStyle(.borderedProminent)
                        if let title = config.primaryButtonTitle {
                            Button(title) { onPrimary() }
                                .keyboardShortcut(.return, modifiers: [])
                                .buttonStyle(.bordered)
                        }
                    }.padding(.top, 20)
                }
            }
            .foregroundStyle(.white)
            .shadow(radius: 8)
            .padding(.horizontal, 24)
        }
        .onAppear {
            if let secs = config.durationSeconds { remaining = secs }
        }
        .onReceive(NotificationCenter.default.publisher(for: .overlayTick)) {
            note in
            if let r = note.userInfo?["remaining"] as? Int {
                remaining = max(0, r)
            }
        }
    }

    @ViewBuilder private var backgroundView: some View {
        ZStack {
            colorFromHex(config.colorHex)
            if let name = config.imageName, !name.isEmpty {
                if let nsImage = loadImage(name: name) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .overlay(Color.black.opacity(0.35))
                }
            }
        }
    }

    private func loadImage(name: String) -> NSImage? {
        if name.hasPrefix("/") || name.contains(".") {
            return NSImage(contentsOfFile: name)
        }
        return NSImage(named: name)
    }

    private func colorFromHex(_ hex: String) -> Color {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { _ = h.removeFirst() }
        guard let val = UInt64(h, radix: 16), h.count == 6 else { return .blue }
        let r = Double((val >> 16) & 0xFF) / 255.0
        let g = Double((val >> 8) & 0xFF) / 255.0
        let b = Double(val & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}
