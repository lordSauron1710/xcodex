//
//  SignalEngine.swift
//  xcodex
//
//  Created by Sandeep Vangara on 1/29/26.
//

import AppKit
import Observation

@MainActor
@Observable
final class SignalEngine {
    var mousePoint: CGPoint
    var isIdle: Bool

    private var lastMousePoint: CGPoint
    private var lastActivityDate: Date
    private var timer: Timer?
    private var currentInterval: TimeInterval

    init() {
        let initialPoint = NSEvent.mouseLocation
        mousePoint = initialPoint
        lastMousePoint = initialPoint
        lastActivityDate = Date()
        isIdle = false
        currentInterval = CompanionConfig.tickInterval
    }

    func start() {
        startTimer(interval: currentInterval)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func setTickInterval(_ interval: TimeInterval) {
        guard interval != currentInterval else { return }
        currentInterval = interval
        startTimer(interval: interval)
    }

    func poll() {
        let point = NSEvent.mouseLocation
        mousePoint = point

        let dx = point.x - lastMousePoint.x
        let dy = point.y - lastMousePoint.y
        let distance = hypot(dx, dy)

        if distance >= CompanionConfig.mouseMovementThreshold {
            lastActivityDate = Date()
            lastMousePoint = point
        }

        let idleThreshold = CompanionConfig.idleMinutes * 60
        isIdle = Date().timeIntervalSince(lastActivityDate) >= idleThreshold
    }

    private func startTimer(interval: TimeInterval) {
        stop()
        let newTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.poll()
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }
}
