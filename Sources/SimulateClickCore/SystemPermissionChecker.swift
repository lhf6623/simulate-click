import Foundation
import ApplicationServices

// ============================================================
// MARK: - 系统权限检查器
// ============================================================
public class SystemPermissionChecker: PermissionChecking {
    public init() {}
    private var authorizationChecked = false

    public func isTrusted() -> Bool {
        AXIsProcessTrusted()
    }

    public func requestPermission(completion: @escaping (Bool) -> Void) {
        if AXIsProcessTrusted() {
            authorizationChecked = true
            completion(true)
            return
        }
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
        pollPermission(remaining: 60, completion: completion)
    }

    private func pollPermission(remaining: Int, completion: @escaping (Bool) -> Void) {
        guard remaining > 0 else {
            completion(false)
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if AXIsProcessTrusted() {
                self.authorizationChecked = true
                completion(true)
            } else {
                self.pollPermission(remaining: remaining - 1, completion: completion)
            }
        }
    }
}
