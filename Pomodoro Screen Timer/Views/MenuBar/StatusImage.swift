//
//  StatusImage.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/20/25.
//

#if os(macOS)
import AppKit

struct StatusAppearance {
    let phase: Phase
    let remaining: Int

    // Tunables
    var fontSize: CGFloat = 13                    // system-ish size for menu bar
    var fontWeight: NSFont.Weight = .semibold
    var colorizeText: Bool = true                 // color timer text by phase

    var iconName: String = "timer"                // looks bigger than "timer.circle.fill"
    var iconWeight: NSFont.Weight = .bold
    /// If nil, we’ll auto-fit icon to status bar height with your padding.
    var iconPointSize: CGFloat? = nil

    // Layout
    var padding = NSEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
    var spacing: CGFloat = 4
    var fixedTemplate: String = "L 100:00"        // locks width for no jiggle
}

func makeStatusImage(_ a: StatusAppearance) -> NSImage {
    // 1) Status bar height cap (don’t exceed or the system scales you down)
    let barH = NSStatusBar.system.thickness       // ~22pt on modern macOS
    let contentH = max(1, barH - (a.padding.top + a.padding.bottom))

    // 2) Font sized to fit content height (monospaced digits, system look)
    let fittedFontSize = min(a.fontSize, contentH)  // don’t exceed content height
    let font = NSFont.monospacedDigitSystemFont(ofSize: fittedFontSize, weight: a.fontWeight)

    // 3) Text
    let mins = a.remaining / 60, secs = a.remaining % 60
    let text = "\(a.phase.shortName) \(String(format: "%02d:%02d", mins, secs))"
    let phaseColor = a.phase.nsColor
    let textColor: NSColor = a.colorizeText ? phaseColor : .labelColor
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: textColor]

    // Fixed text width from template
    let fixedTextSize = (a.fixedTemplate as NSString).size(withAttributes: attrs)

    // 4) Icon sized to content height (slightly less so it doesn’t clip)
    let desiredIconPt = a.iconPointSize ?? (contentH)   // fill available height
    let iconCfg = NSImage.SymbolConfiguration(pointSize: desiredIconPt, weight: a.iconWeight)
    // Palette/hierarchical; use palette for two-tone or hierarchical for single-tone
    let pal = NSImage.SymbolConfiguration(paletteColors: [phaseColor, phaseColor.withAlphaComponent(0.25)])
    let base = NSImage(systemSymbolName: a.iconName, accessibilityDescription: nil)?
        .withSymbolConfiguration(iconCfg)?
        .withSymbolConfiguration(pal)
    let iconSize = base?.size ?? NSSize(width: desiredIconPt, height: desiredIconPt)

    // 5) Canvas sized exactly to status bar (prevents OS downscaling)
    let totalW = a.padding.left + iconSize.width + a.spacing + fixedTextSize.width + a.padding.right
    let size = NSSize(width: ceil(totalW), height: ceil(barH))
    let img = NSImage(size: size)
    img.lockFocus()

    // Baseline Y so icon/text are vertically centered in the bar
    let iconY = (size.height - iconSize.height)/2
    let textY = (size.height - fixedTextSize.height)/2

    // Draw icon
    if let base {
        base.draw(in: NSRect(x: a.padding.left, y: iconY, width: iconSize.width, height: iconSize.height))
    }

    // Draw fixed-width text (no jiggle)
    let textX = a.padding.left + iconSize.width + a.spacing
    (text as NSString).draw(at: NSPoint(x: textX, y: textY), withAttributes: attrs)

    img.unlockFocus()
    img.isTemplate = false
    return img
}
#endif
