//
//  PhysicsEngine.swift
//  xcodex
//
//  Created by Sandeep Vangara on 1/29/26.
//

import CoreGraphics
import Foundation

struct PhysicsEngine {
    enum Event: Equatable {
        case poke
        case doublePoke
        case stateChanged(from: CompanionState, to: CompanionState)
    }

    struct Output {
        let position: CGPoint
        let velocity: CGVector
        let state: CompanionState
        let events: [Event]
        let squashX: CGFloat
        let squashY: CGFloat
        let highlightDirection: CGVector
    }

    private var lastState: CompanionState = .idlePerch
    private var timeSinceLastPoke: TimeInterval = .greatestFiniteMagnitude
    private var pokeCooldownRemaining: TimeInterval = 0
    private var doublePokeCooldownRemaining: TimeInterval = 0

    mutating func step(
        position: CGPoint,
        velocity: CGVector,
        cursor: CGPoint,
        isFocusOn: Bool,
        isIdle: Bool,
        dt: TimeInterval
    ) -> Output {
        let safeDt = max(dt, 0.0001)
        pokeCooldownRemaining = max(0, pokeCooldownRemaining - safeDt)
        doublePokeCooldownRemaining = max(0, doublePokeCooldownRemaining - safeDt)
        timeSinceLastPoke += safeDt

        let toCursor = cursor - position
        let distanceToCursor = length(toCursor)
        let highlightDirection = normalized(toCursor, fallback: CGVector(dx: 0, dy: -1))

        var events: [Event] = []
        var state = CompanionState.idlePerch
        var newVelocity = velocity
        var newPosition = position

        if isFocusOn {
            state = .focus
        } else if isIdle {
            state = .sleep
        } else if distanceToCursor <= CompanionConfig.pokeInnerRadius, pokeCooldownRemaining <= 0 {
            state = .bounce
            events.append(.poke)

            if timeSinceLastPoke <= CompanionConfig.doublePokeWindow, doublePokeCooldownRemaining <= 0 {
                events.append(.doublePoke)
                doublePokeCooldownRemaining = CompanionConfig.doublePokeCooldown
            }

            timeSinceLastPoke = 0
            pokeCooldownRemaining = CompanionConfig.pokeCooldown

            let awayFromCursor = normalized(position - cursor, fallback: CGVector(dx: 0, dy: 1))
            newVelocity = awayFromCursor * CGFloat(CompanionConfig.bounceImpulse)
        } else if distanceToCursor <= CompanionConfig.attractRadius {
            state = .curious
        } else {
            state = .idlePerch
        }

        switch state {
        case .curious:
            let result = springStep(
                position: position,
                velocity: newVelocity,
                target: cursor,
                frequency: CompanionConfig.springFrequency,
                dampingRatio: CompanionConfig.dampingRatio,
                dt: safeDt
            )
            newPosition = result.position
            newVelocity = result.velocity
        case .bounce:
            newVelocity = applyDamping(newVelocity, damping: CompanionConfig.bounceDamping, dt: safeDt)
            newPosition = position + newVelocity * CGFloat(safeDt)
        case .idlePerch:
            newVelocity = applyDamping(newVelocity, damping: CompanionConfig.idleDamping, dt: safeDt)
            newPosition = position + newVelocity * CGFloat(safeDt)
        case .focus:
            newVelocity = applyDamping(newVelocity, damping: CompanionConfig.focusDamping, dt: safeDt)
            newPosition = position + newVelocity * CGFloat(safeDt)
        case .sleep:
            newVelocity = applyDamping(newVelocity, damping: CompanionConfig.sleepDamping, dt: safeDt)
            newPosition = position + newVelocity * CGFloat(safeDt)
        }

        newVelocity = clampSpeed(newVelocity, maxSpeed: CompanionConfig.maxSpeed)

        let speed = length(newVelocity)
        let intensity = min(speed / CGFloat(CompanionConfig.maxSpeed), 1)
        let squashX = 1 + intensity * CompanionConfig.maxStretch
        let squashY = 1 - intensity * CompanionConfig.maxSquash

        if state != lastState {
            events.append(.stateChanged(from: lastState, to: state))
            lastState = state
        }

        return Output(
            position: newPosition,
            velocity: newVelocity,
            state: state,
            events: events,
            squashX: squashX,
            squashY: squashY,
            highlightDirection: highlightDirection
        )
    }
}

private func springStep(
    position: CGPoint,
    velocity: CGVector,
    target: CGPoint,
    frequency: Double,
    dampingRatio: Double,
    dt: TimeInterval
) -> (position: CGPoint, velocity: CGVector) {
    let omega = 2 * Double.pi * frequency
    let x = position - target
    let accel = (-2 * dampingRatio * omega) * velocity - (omega * omega) * x
    let newVelocity = velocity + accel * CGFloat(dt)
    let newPosition = position + newVelocity * CGFloat(dt)
    return (position: newPosition, velocity: newVelocity)
}

private func applyDamping(_ velocity: CGVector, damping: Double, dt: TimeInterval) -> CGVector {
    let factor = exp(-damping * dt)
    return velocity * CGFloat(factor)
}

private func clampSpeed(_ velocity: CGVector, maxSpeed: Double) -> CGVector {
    let speed = length(velocity)
    let maxSpeedValue = CGFloat(maxSpeed)
    guard speed > maxSpeedValue else { return velocity }
    return velocity * (maxSpeedValue / speed)
}

private func length(_ vector: CGVector) -> CGFloat {
    hypot(vector.dx, vector.dy)
}

private func normalized(_ vector: CGVector, fallback: CGVector) -> CGVector {
    let magnitude = length(vector)
    guard magnitude > 0 else { return fallback }
    return vector * (1 / magnitude)
}

private func - (lhs: CGPoint, rhs: CGPoint) -> CGVector {
    CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
}

private func + (lhs: CGPoint, rhs: CGVector) -> CGPoint {
    CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
}

private func * (lhs: CGVector, rhs: CGFloat) -> CGVector {
    CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}

private func - (lhs: CGVector, rhs: CGVector) -> CGVector {
    CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
}

private func + (lhs: CGVector, rhs: CGVector) -> CGVector {
    CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
}

private func * (lhs: Double, rhs: CGVector) -> CGVector {
    CGVector(dx: rhs.dx * lhs, dy: rhs.dy * lhs)
}

private func * (lhs: CGVector, rhs: Double) -> CGVector {
    CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}
