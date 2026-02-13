//
//  DurationRow.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import SwiftUI

struct DurationRow: View {
    let title: String
    let stepRange: ClosedRange<Int>
    @Binding var binding: Int
    var unit: String
    
    var body: some View {
        GridRow {
            Text(title)
            HStack(spacing: 8) {
                TextField("", value: $binding, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 50)
                    .multilineTextAlignment(.trailing)
                    .onSubmit {
                        $binding.wrappedValue = $binding.wrappedValue.clamped(to: stepRange)
                    }

                if !unit.isEmpty {
                    Text(unit).foregroundStyle(.secondary)
                }

                Stepper("", value: $binding, in: stepRange)
                    .labelsHidden()
            }
        }
    }
}

