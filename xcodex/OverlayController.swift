//
//  OverlayController.swift
//  xcodex
//
//  Created by Sandeep Vangara on 1/29/26.
//

import AppKit
import SwiftUI

@MainActor
final class OverlayController {
    private let window: OverlayWindow
    private let hostingView: NSHostingView<CompanionView>
    private let contentSize: CGSize

    init(model: CompanionModel) {
        contentSize = CGSize(width: CompanionConfig.ballDiameter, height: CompanionConfig.ballDiameter)
        hostingView = NSHostingView(rootView: CompanionView(model: model))
        hostingView.frame = CGRect(origin: .zero, size: contentSize)

        window = OverlayWindow(
            contentRect: CGRect(origin: .zero, size: contentSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = true
        window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.hasShadow = false
        window.contentView = hostingView
    }

    func show() {
        window.orderFrontRegardless()
    }

    func hide() {
        window.orderOut(nil)
    }

    func updatePosition(_ point: CGPoint) {
        guard let screen = NSScreen.main else { return }
        let visibleFrame = screen.visibleFrame

        let proposedOrigin = CGPoint(
            x: point.x - contentSize.width / 2,
            y: point.y - contentSize.height / 2
        )

        let clampedX = min(max(proposedOrigin.x, visibleFrame.minX), visibleFrame.maxX - contentSize.width)
        let clampedY = min(max(proposedOrigin.y, visibleFrame.minY), visibleFrame.maxY - contentSize.height)
        window.setFrameOrigin(NSPoint(x: clampedX, y: clampedY))
    }

    private final class OverlayWindow: NSWindow {
        override var canBecomeKey: Bool { false }
        override var canBecomeMain: Bool { false }
    }
}
