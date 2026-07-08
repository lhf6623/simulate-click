import Foundation
import CoreGraphics

// ============================================================
// MARK: - 点击引擎协议
// ============================================================
public protocol Clicking {
    func performClick(x: Int, y: Int)
}

// ============================================================
// MARK: - 真实点击引擎（需要辅助功能权限）
// ============================================================
public class ClickEngine: Clicking {
    public init() {}
    public func performClick(x: Int, y: Int) {
        let point = CGPoint(x: x, y: y)
        CGWarpMouseCursorPosition(point)
        guard let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                                  mouseCursorPosition: point, mouseButton: .left),
              let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                                mouseCursorPosition: point, mouseButton: .left) else { return }
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }
}
