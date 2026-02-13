//
//  Comparable+Extensions.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import Foundation

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        // self is the 1st number (the value)
        // range.lowerBound is the 2nd number (lo)
        // range.upperBound is the 3rd number (hi)
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
