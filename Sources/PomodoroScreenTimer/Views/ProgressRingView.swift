//
//  ProgressRingView.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import SwiftUI

struct ProgressRingView: View {
    let progress: Double          // 0...1
    let phase: Phase

    // Sizing & content
    var size: CGFloat = 300       // ring diameter
    var centerText: String        // time string
    var isRunning: Bool           // for the icon
    var onToggle: () -> Void      // start/pause action

    @State private var isHovered: Bool = false
    
    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(phaseColor.opacity(0.15), lineWidth: ringWidth)

            // Progress
            Circle()
                .trim(from: 0, to: CGFloat(clampedProgress))
                .stroke(
                    phaseColor,
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.35), value: progress)

            // Center content (time, phase, button)
            VStack(spacing: size * 0.02) {
                // Phase label
                Text(phase.displayName)
                    .font(.system(size: max(12, size * 0.08), weight: .medium))
                    .foregroundStyle(.secondary)
                
                // Time
                Text(centerText)
                    .font(.system(size: max(28, size * 0.26), weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .foregroundColor(phaseColor)
                    .lineLimit(1)

                // Icon-only Start/Pause inside the ring
                Button(action: onToggle) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: max(18, size * 0.12), weight: .bold))
                        .foregroundStyle(phase.isBreak ? Color.red : Color.green) // colored icon
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .padding(.top, size * 0.01)
                .onHover { hover in
                    isHovered = hover
                    if hover { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }.animation(.easeOut(duration: 0.15), value: isHovered)
            }
            .frame(width: size * 0.75) // keep the stack nicely inside the ring
        }
        .frame(width: size, height: size)
        .padding(8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(phase.displayName) progress")
        .accessibilityValue(Text("\(Int(progress * 100)) percent"))
    }

    // MARK: Computed
    private var clampedProgress: Double { max(0, min(1, progress)) }
    private var ringWidth: CGFloat { max(14, min(32, size * 0.085)) }
    private var phaseColor: Color { phase.color }
}
