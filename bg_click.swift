import Foundation
import CoreGraphics

// 后台鼠标点击工具
// 通过 CGWarpMouseCursorPosition 移动光标 + CGEventPost 点击
// 通过 stdin 接收命令：
//   click X Y [left|right|middle]
//   ping
//   quit

func postClick(x: Int, y: Int) {
    let targetPoint = CGPoint(x: x, y: y)

    // 移动光标到目标位置
    CGWarpMouseCursorPosition(targetPoint)

    // 创建并发送左键点击事件
    guard let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: targetPoint, mouseButton: .left),
          let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: targetPoint, mouseButton: .left) else {
        print("err:failed to create event")
        fflush(stdout)
        return
    }

    mouseDown.post(tap: .cghidEventTap)
    mouseUp.post(tap: .cghidEventTap)
}

print("ready")
fflush(stdout)

while let line = readLine(strippingNewline: true) {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { continue }
    if trimmed == "quit" { break }
    if trimmed == "ping" {
        print("pong")
        fflush(stdout)
        continue
    }

    let parts = trimmed.split(separator: " ")
    if parts.count >= 3 && parts[0] == "click" {
        let x = Int(parts[1]) ?? 0
        let y = Int(parts[2]) ?? 0
        autoreleasepool {
            postClick(x: x, y: y)
        }
    }
}
