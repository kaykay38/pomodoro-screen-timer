//
//  SettingsGridRow.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import SwiftUI

struct SettingsGridRow<Content: View>: View {
    let label: String
    let content: Content

    // Using an initializer with @ViewBuilder allows for the trailing closure syntax
    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        GridRow {
            Text(label)
            content
        }
    }
}
