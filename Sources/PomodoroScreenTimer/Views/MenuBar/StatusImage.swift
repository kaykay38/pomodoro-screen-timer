//
//  StatusImage.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/20/25.
//

import AppKit

struct StatusAppearance {
    let phase: Phase
    let remaining: Int
    
    // Instead of a fixed font size, we use a ratio of the bar height
    var textScale: CGFloat = 0.65  // 65% of bar height
    var iconScale: CGFloat = 0.75  // 75% of bar height
    
    var fontWeight: NSFont.Weight = .semibold
    var colorizeText: Bool = true
    var iconName: String = "timer"
    var iconWeight: NSFont.Weight = .bold
    
    var padding = NSEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
    var spacing: CGFloat = 2
}

func makeStatusImage(_ a: StatusAppearance) -> NSImage {
    let barH = NSStatusBar.system.thickness
    
    // Calculate dynamic sizes based on the CURRENT bar height
    let dynamicFontSize = barH * a.textScale
    let dynamicIconSize = barH * a.iconScale
    
    let font = NSFont.monospacedDigitSystemFont(ofSize: dynamicFontSize, weight: a.fontWeight)
    
    let mins = a.remaining / 60, secs = a.remaining % 60
    let text = String(format: "%02d:%02d", mins, secs)
    let phaseColor = a.phase.nsColor
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: a.colorizeText ? phaseColor : .labelColor
    ]

    // Use a template to fix the width so the menu bar doesn't "jump"
    let templateWidth = ("00:00" as NSString).size(withAttributes: attrs).width
    let iconCfg = NSImage.SymbolConfiguration(pointSize: dynamicIconSize, weight: a.iconWeight)
    let pal = NSImage.SymbolConfiguration(paletteColors: [phaseColor, phaseColor.withAlphaComponent(0.3)])
    
    guard let base = NSImage(systemSymbolName: a.iconName, accessibilityDescription: nil)?
        .withSymbolConfiguration(iconCfg)?
        .withSymbolConfiguration(pal) else { return NSImage() }

    let iconSize = base.size
    let totalW = a.padding.left + iconSize.width + a.spacing + templateWidth + a.padding.right
    
    let img = NSImage(size: NSSize(width: ceil(totalW), height: barH))
    img.lockFocus()

    // Perfect vertical centering
    let iconY = (barH - iconSize.height) / 2
    let textY = (barH - font.ascender + font.descender) / 2 // Better optical centering for text

    base.draw(in: NSRect(x: a.padding.left, y: iconY, width: iconSize.width, height: iconSize.height))
    
    // Draw text centered in its reserved template space
    (text as NSString).draw(at: NSPoint(x: a.padding.left + iconSize.width + a.spacing, y: textY), withAttributes: attrs)

    img.unlockFocus()
    return img
}
