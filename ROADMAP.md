Prompt 0 — Ground rules (run once) // EXECUTED
Before writing any code:
- Read and follow AGENTS.md. If anything conflicts, AGENTS.md takes precedence.
- Target macOS only, Swift 6.2+, SwiftUI App lifecycle.
- Use @Observable classes marked @MainActor for shared state.
- No ObservableObject, no third-party frameworks.
- No external assets, no networking.
- Keep CPU low and code testable.
Acknowledge by replying: "AGENTS.md loaded and understood."

Prompt 1 — App state + config // EXECUTED
Create CompanionConfig.swift and CompanionAppState.swift.

CompanionConfig:
- Centralize all tunable constants (ball size, radii, physics, tick rate).
- Use static lets.

CompanionAppState:
- @Observable, @MainActor.
- Holds:
  - isFocusOn: Bool
  - isCompanionVisible: Bool
  - anchorPreset enum (bottomRight, bottomLeft)

One type per file. No UI code.
Output code only, grouped by filename.

Prompt 2 — Menu bar controller
Create MenuBarController.swift.

Responsibilities:
- Add an NSStatusBar icon.
- Build an NSMenu with:
  - Focus On/Off toggle
  - Show/Hide Companion toggle
  - Position preset: Bottom-right / Bottom-left
  - Quit
- Mutate CompanionAppState when menu items change.
- No view rendering logic here.

Stay compliant with AGENTS.md.
Output code only.

Prompt 3 — Overlay window
Create OverlayController.swift.

Responsibilities:
- Create a transparent, borderless, always-on-top NSWindow.
- Configure:
  - isOpaque = false
  - backgroundColor = .clear
  - ignoresMouseEvents = true
  - does not become key or main
  - canJoinAllSpaces, fullScreenAuxiliary
- Host CompanionView via NSHostingView.
- Provide methods:
  - show()
  - hide()
  - updatePosition(CGPoint)
- Clamp window to visibleFrame of main screen.

No physics or cursor logic here.
Output code only.

Prompt 4 — Signal engine (cursor + idle)
Create SignalEngine.swift.

Requirements:
- @Observable, @MainActor.
- Poll NSEvent.mouseLocation at 30 Hz using Timer.
- Publish:
  - mousePoint: CGPoint
  - isIdle: Bool
- Track lastActivityDate based on meaningful mouse movement.
- Enter idle after CompanionConfig.idleMinutes.

Mouse-only signals. Avoid permissions.
Output code only.

Prompt 5 — Physics engine (pure logic)
Create PhysicsEngine.swift.

Requirements:
- No SwiftUI or AppKit imports.
- Pure logic, fully testable.
- Implement:
  - Critically damped spring toward a target.
  - Velocity and position updates.
  - Speed clamp.
  - Poke detection (inner radius).
  - Double-poke detection (time window).
  - Cooldowns.

Inputs:
- Current position, velocity
- Cursor position
- State flags (focus, idle)
- dt

Outputs:
- New position
- New velocity
- State transition events
- Squash/stretch factors
- Highlight direction

Output code only.

Prompt 6 — Companion model
Create CompanionModel.swift.

Requirements:
- @Observable, @MainActor.
- Holds:
  - position
  - velocity
  - state enum (idlePerch, curious, bounce, focus, sleep)
  - squashX, squashY
  - highlightDirection
  - breathingPhase
- Owns a PhysicsEngine instance.
- Exposes step(dt:, signals:) to update itself.

No rendering code here.
Output code only.

Prompt 7 — Companion view (procedural ball)
Create CompanionView.swift.

Requirements:
- SwiftUI view.
- Procedurally render a ball (no assets) using Canvas.
- Visual elements:
  - Radial gradient body
  - Rim shading
  - Highlight driven by highlightDirection
  - Optional soft shadow
- Apply squash/stretch transforms.
- No physics or timers inside the view.
- Use foregroundStyle(), avoid hard-coded fonts/sizes.

Output code only.

Prompt 8 — App wiring
Wire everything together.

Tasks:
- Initialize CompanionAppState, SignalEngine, CompanionModel.
- Start 30 Hz update loop using Timer (no DispatchQueue).
- On each tick:
  - Update signals
  - Step CompanionModel
  - Update OverlayController window position
- Reduce or stop tick in Focus and Sleep states.
- Ensure app launches with menubar icon and visible companion.

Only update ContentView.swift or App entry point as needed.
Output code only.

Prompt 9 — Unit tests
Create PhysicsEngineTests.swift.

Tests:
- Spring converges to target.
- Speed is clamped.
- Poke triggers bounce.
- Double-poke triggers flourish event.
- State transitions behave correctly.

Use XCTest.
No UI tests.
Output code only.
