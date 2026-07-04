import Foundation
import AppKit

// 辅助功能权限检测和请求工具
// 用法：
//   check_perm          - 检查权限，没有则弹出系统授权对话框
//   check_perm --reset  - 重置权限（用于调试）

if CommandLine.arguments.contains("--reset") {
    // 重置辅助功能权限（调试用）
    let url = URL(fileURLWithPath: "/Users/lhf/Documents/GitHub/personal/simulate-click/node_modules/electron/dist/Electron.app")
    let prefs = [
        "kTCCServiceAccessibility": [
            "allowed": false,
            "last_modified": Date()
        ]
    ] as [String: Any]
    // 提示用户手动操作
    print("请在终端运行以下命令重置权限：")
    print("sudo tccutil reset Accessibility")
    exit(0)
}

// 检查并请求辅助功能权限
// kAXTrustedCheckOptionPrompt = true 会自动弹出系统授权对话框
let options: CFDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
let trusted = AXIsProcessTrustedWithOptions(options)

if trusted {
    print("granted")
} else {
    // 再次检查（用户可能在对话框中点了拒绝）
    let recheck = AXIsProcessTrusted()
    print(recheck ? "granted" : "denied")
}
fflush(stdout)
