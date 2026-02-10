import AppKit

extension NSScreen {
    var hasNotch: Bool {
        safeAreaInsets.top > 0
    }

    var notchRect: NSRect? {
        guard hasNotch else { return nil }
        let fullWidth = frame.width
        guard let leftArea = auxiliaryTopLeftArea,
              let rightArea = auxiliaryTopRightArea else {
            return nil
        }
        let notchLeft = leftArea.maxX
        let notchRight = rightArea.minX
        let notchWidth = notchRight - notchLeft
        let notchHeight = safeAreaInsets.top
        return NSRect(
            x: frame.origin.x + notchLeft,
            y: frame.origin.y + frame.height - notchHeight,
            width: notchWidth,
            height: notchHeight
        )
    }

    var cameraCenter: CGPoint {
        if let notch = notchRect {
            return CGPoint(
                x: notch.midX,
                y: frame.origin.y + frame.height
            )
        }
        return CGPoint(
            x: frame.midX,
            y: frame.origin.y + frame.height
        )
    }

    static var screenWithNotch: NSScreen? {
        screens.first { $0.hasNotch }
    }
}
