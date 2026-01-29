//
//  CompanionConfig.swift
//  xcodex
//
//  Created by Sandeep Vangara on 1/29/26.
//

import CoreGraphics
import Foundation

struct CompanionConfig {
    // Ball sizing
    static let ballDiameter: CGFloat = 56
    static let ballRadius: CGFloat = ballDiameter / 2

    // Interaction radii
    static let pokeInnerRadius: CGFloat = 24
    static let pokeOuterRadius: CGFloat = 80
    static let attractRadius: CGFloat = 140

    // Physics tuning
    static let springFrequency: Double = 6.0
    static let dampingRatio: Double = 1.0
    static let maxSpeed: Double = 900
    static let bounceImpulse: Double = 760
    static let bounceDamping: Double = 3.8
    static let idleDamping: Double = 5.5
    static let focusDamping: Double = 10.0
    static let sleepDamping: Double = 12.0
    static let pokeCooldown: TimeInterval = 0.35
    static let doublePokeWindow: TimeInterval = 0.5
    static let doublePokeCooldown: TimeInterval = 1.0
    static let maxStretch: CGFloat = 0.18
    static let maxSquash: CGFloat = 0.14

    // Timing
    static let tickHz: Double = 30
    static let tickInterval: TimeInterval = 1.0 / tickHz
    static let idleMinutes: Double = 2.0
    static let mouseMovementThreshold: CGFloat = 1.25
}
