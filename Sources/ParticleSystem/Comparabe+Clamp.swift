//
//  Double+Clamp.swift
//  Wind
//
//  Created by Labtanza on 6/21/22.
//

import Foundation

public extension Comparable {
  func clamped(to limits: ClosedRange<Self>) -> Self {
    min(Swift.max(limits.lowerBound, self), limits.upperBound)
  }
}

public extension Strideable where Stride: SignedInteger {
  func clamped(to limits: Range<Self>) -> Self {
    clamped(to: ClosedRange(limits))
  }
}
