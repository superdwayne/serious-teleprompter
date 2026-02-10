import SwiftUI
import AppKit

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = WindowAccessorView()
        view.onWindowAvailable = { window in
            configureWindow(window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    private final class WindowAccessorView: NSView {
        var onWindowAvailable: ((NSWindow) -> Void)?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard let window else { return }
            // Defer to avoid layout recursion
            DispatchQueue.main.async { [weak self] in
                self?.onWindowAvailable?(window)
            }
        }
    }

    private func configureWindow(_ window: NSWindow) {
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden

        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        if let panel = window as? NSPanel {
            panel.isFloatingPanel = true
            panel.becomesKeyOnlyIfNeeded = true
        }

        let notchDetector = NotchDetector()
        notchDetector.calculateWindowOrigin(for: window.screen ?? NSScreen.main!, windowWidth: window.frame.width)
        window.setFrameOrigin(notchDetector.windowOrigin)
    }
}
