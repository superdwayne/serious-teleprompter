import AppKit

final class KeyboardShortcutManager {
    private var monitors: [Any] = []

    typealias Action = @MainActor () -> Void

    struct Shortcut {
        let key: UInt16
        let modifiers: NSEvent.ModifierFlags
        let action: Action
    }

    @MainActor
    func register(shortcuts: [Shortcut]) {
        unregisterAll()

        let globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [shortcuts] event in
            for shortcut in shortcuts {
                if event.keyCode == shortcut.key &&
                    event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(shortcut.modifiers) {
                    Task { @MainActor in
                        shortcut.action()
                    }
                    break
                }
            }
        }

        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [shortcuts] event in
            for shortcut in shortcuts {
                if event.keyCode == shortcut.key &&
                    event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(shortcut.modifiers) {
                    Task { @MainActor in
                        shortcut.action()
                    }
                    return nil
                }
            }
            return event
        }

        if let globalMonitor { monitors.append(globalMonitor) }
        if let localMonitor { monitors.append(localMonitor) }
    }

    func unregisterAll() {
        for monitor in monitors {
            NSEvent.removeMonitor(monitor)
        }
        monitors.removeAll()
    }

    deinit {
        unregisterAll()
    }
}

// Key codes for common keys
extension KeyboardShortcutManager {
    // T = 0x11, Space = 0x31, Up = 0x7E, Down = 0x7D, R = 0x0F
    static let keyT: UInt16 = 0x11
    static let keySpace: UInt16 = 0x31
    static let keyUp: UInt16 = 0x7E
    static let keyDown: UInt16 = 0x7D
    static let keyR: UInt16 = 0x0F
}
