//
//  MenuBarController.swift
//  xcodex
//
//  Created by Sandeep Vangara on 1/29/26.
//

import AppKit

@MainActor
final class MenuBarController: NSObject, NSMenuDelegate {
    private let appState: CompanionAppState
    private let statusItem: NSStatusItem
    private let menu: NSMenu

    private let focusItem: NSMenuItem
    private let visibilityItem: NSMenuItem
    private let positionMenuItem: NSMenuItem
    private let bottomRightItem: NSMenuItem
    private let bottomLeftItem: NSMenuItem
    private let quitItem: NSMenuItem

    init(appState: CompanionAppState) {
        self.appState = appState
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        menu = NSMenu()

        focusItem = NSMenuItem(
            title: "Focus On",
            action: #selector(toggleFocus(_:)),
            keyEquivalent: ""
        )
        visibilityItem = NSMenuItem(
            title: "Hide Companion",
            action: #selector(toggleVisibility(_:)),
            keyEquivalent: ""
        )
        positionMenuItem = NSMenuItem(title: "Position", action: nil, keyEquivalent: "")
        bottomRightItem = NSMenuItem(
            title: "Bottom-right",
            action: #selector(setBottomRight(_:)),
            keyEquivalent: ""
        )
        bottomLeftItem = NSMenuItem(
            title: "Bottom-left",
            action: #selector(setBottomLeft(_:)),
            keyEquivalent: ""
        )
        quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp(_:)),
            keyEquivalent: "q"
        )

        super.init()

        focusItem.target = self
        visibilityItem.target = self
        bottomRightItem.target = self
        bottomLeftItem.target = self
        quitItem.target = self

        menu.delegate = self
        menu.addItem(focusItem)
        menu.addItem(visibilityItem)
        menu.addItem(.separator())

        let positionMenu = NSMenu(title: "Position")
        positionMenu.addItem(bottomRightItem)
        positionMenu.addItem(bottomLeftItem)
        positionMenuItem.submenu = positionMenu
        menu.addItem(positionMenuItem)

        menu.addItem(.separator())
        menu.addItem(quitItem)

        statusItem.menu = menu

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "circle.dotted", accessibilityDescription: "Companion")
            button.image?.isTemplate = true
        }

        updateMenuState()
    }

    func menuWillOpen(_ menu: NSMenu) {
        updateMenuState()
    }

    @objc private func toggleFocus(_ sender: NSMenuItem) {
        appState.isFocusOn.toggle()
        updateMenuState()
    }

    @objc private func toggleVisibility(_ sender: NSMenuItem) {
        appState.isCompanionVisible.toggle()
        updateMenuState()
    }

    @objc private func setBottomRight(_ sender: NSMenuItem) {
        appState.anchorPreset = .bottomRight
        updateMenuState()
    }

    @objc private func setBottomLeft(_ sender: NSMenuItem) {
        appState.anchorPreset = .bottomLeft
        updateMenuState()
    }

    @objc private func quitApp(_ sender: NSMenuItem) {
        NSApp.terminate(nil)
    }

    private func updateMenuState() {
        focusItem.title = appState.isFocusOn ? "Focus Off" : "Focus On"
        focusItem.state = appState.isFocusOn ? .on : .off

        visibilityItem.title = appState.isCompanionVisible ? "Hide Companion" : "Show Companion"
        visibilityItem.state = appState.isCompanionVisible ? .on : .off

        bottomRightItem.state = appState.anchorPreset == .bottomRight ? .on : .off
        bottomLeftItem.state = appState.anchorPreset == .bottomLeft ? .on : .off
    }
}
