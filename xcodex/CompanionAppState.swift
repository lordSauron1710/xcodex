//
//  CompanionAppState.swift
//  xcodex
//
//  Created by Sandeep Vangara on 1/29/26.
//

import Observation

@MainActor
@Observable
final class CompanionAppState {
    enum AnchorPreset {
        case bottomRight
        case bottomLeft
    }

    var isFocusOn: Bool = false
    var isCompanionVisible: Bool = true
    var anchorPreset: AnchorPreset = .bottomRight
}
