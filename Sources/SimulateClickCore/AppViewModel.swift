import Foundation
import Combine

// ============================================================
// MARK: - 权限检查协议
// ============================================================
public protocol PermissionChecking {
    func isTrusted() -> Bool
    func requestPermission(completion: @escaping (Bool) -> Void)
}

// ============================================================
// MARK: - ViewModel
// ============================================================
public class AppViewModel: ObservableObject {
    @Published public var countLimitText = "1"
    @Published public var posXText = "0"
    @Published public var posYText = "0"
    @Published public var minDelayText = "500"
    @Published public var maxDelayText = "1500"
    @Published public var isRunning = false
    @Published public var clickCount = 0
    @Published public var isCapturing = false

    private var timer: DispatchSourceTimer?

    public var countLimit: Int { Int(countLimitText) ?? 1 }
    public var posX: Int { Int(posXText) ?? 0 }
    public var posY: Int { Int(posYText) ?? 0 }
    public var minDelay: Int { max(Int(minDelayText) ?? 500, 10) }
    public var maxDelay: Int { max(Int(maxDelayText) ?? 1500, 10) }

    private let clicker: Clicking
    private let permissionChecker: PermissionChecking

    public init(clicker: Clicking = ClickEngine(),
                permissionChecker: PermissionChecking = SystemPermissionChecker()) {
        self.clicker = clicker
        self.permissionChecker = permissionChecker
    }

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        clickCount = 0
        permissionChecker.requestPermission { [weak self] granted in
            guard let self, granted else {
                DispatchQueue.main.async { [weak self] in
                    self?.isRunning = false
                }
                return
            }
            DispatchQueue.main.async {
                self.scheduleNextClick()
            }
        }
    }

    public func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
    }

    public func scheduleNextClick() {
        guard isRunning else { return }
        clicker.performClick(x: posX, y: posY)
        clickCount += 1
        if countLimit > 0 && clickCount >= countLimit {
            stop()
            return
        }
        let delay = Self.computeDelay(minDelay: minDelay, maxDelay: maxDelay)
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now() + delay)
        timer?.setEventHandler { [weak self] in self?.scheduleNextClick() }
        timer?.resume()
    }

    /// 计算下次点击的延迟时间（秒），抽离为静态方法便于测试
    public static func computeDelay(minDelay: Int, maxDelay: Int) -> TimeInterval {
        minDelay == maxDelay
            ? TimeInterval(minDelay) / 1000.0
            : TimeInterval(Int.random(in: minDelay...maxDelay)) / 1000.0
    }
}
