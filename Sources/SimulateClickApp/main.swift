import SwiftUI
import AppKit
import SimulateClickCore

// ============================================================
// MARK: - SwiftUI 主界面
// ============================================================
struct ContentView: View {
    @ObservedObject var vm: AppViewModel

    var body: some View {
        VStack(spacing: 6) {
            // 点击次数
            card {
                sectionHeader("点击次数 (0为不限)", status: vm.isRunning ? "运行中" : "空闲", running: vm.isRunning)
                NumericField(text: $vm.countLimitText)
                    .frame(height: 28)
            }

            // 位置
            card {
                sectionHeader("位置")
                HStack(spacing: 5) {
                    Text("X").font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.35)).frame(width: 14)
                    NumericField(text: $vm.posXText)
                    Text("Y").font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.35)).frame(width: 14)
                    NumericField(text: $vm.posYText)
                    Button("捕获") {
                        vm.isCapturing = true
                        CaptureOverlay.show { x, y in
                            vm.posXText = "\(x)"
                            vm.posYText = "\(y)"
                            vm.isCapturing = false
                            NSApp.activate(ignoringOtherApps: true)
                        } cancelled: {
                            vm.isCapturing = false
                            NSApp.activate(ignoringOtherApps: true)
                        }
                    }
                    .buttonStyle(MiniButtonStyle(isWaiting: vm.isCapturing))
                }
            }

            // 间隔
            card {
                sectionHeader("间隔 (毫秒)")
                HStack(spacing: 5) {
                    NumericField(text: $vm.minDelayText)
                    Text("~").font(.system(size: 14)).foregroundColor(.white.opacity(0.2))
                    NumericField(text: $vm.maxDelayText)
                }
            }

            // 开始/停止按钮
            if !vm.isRunning {
                Button("开始") { vm.start() }
                    .buttonStyle(ActionButtonStyle(color: .green))
                    .frame(height: 32)
            } else {
                Button("停止 (Esc)  ·  已点击 \(vm.clickCount) 次") { vm.stop() }
                    .buttonStyle(ActionButtonStyle(color: .red))
                    .frame(height: 32)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .animation(.easeInOut(duration: 0.2), value: vm.isRunning)
    }

    /// 卡片容器：半透明背景 + 圆角 + 微边框
    @ViewBuilder
    func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
        }
        .padding(8)
        .background(Color.white.opacity(0.07))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .cornerRadius(8)
    }

    @ViewBuilder
    func sectionHeader(_ label: String, status: String? = nil, running: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.45))
            Spacer()
            if let status {
                HStack(spacing: 3) {
                    Circle()
                        .fill(running ? Color.green : Color.white.opacity(0.25))
                        .frame(width: 5, height: 5)
                        .shadow(color: running ? .green.opacity(0.6) : .clear, radius: 2)
                    Text(status)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
    }
}

// ============================================================
// MARK: - 按钮样式
// ============================================================
struct MiniButtonStyle: ButtonStyle {
    var isWaiting = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isWaiting ? .yellow : .white.opacity(0.7))
            .frame(width: 52, height: 28)
            .background(isWaiting ? Color.yellow.opacity(0.15) : Color.white.opacity(0.06))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(
                isWaiting ? Color.yellow.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 0.5))
            .cornerRadius(5)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

struct ActionButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.6 : 0.75))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(color.opacity(0.4), lineWidth: 0.5))
            .cornerRadius(7)
    }
}

// ============================================================
// MARK: - 数字输入框
// ============================================================
struct NumericField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""

    func makeNSView(context: Context) -> StyledTextField {
        let field = StyledTextField()
        field.delegate = context.coordinator
        field.heightAnchor.constraint(equalToConstant: 28).isActive = true
        field.placeholderString = placeholder.isEmpty ? nil : placeholder
        return field
    }
    func updateNSView(_ nsView: StyledTextField, context: Context) {
        if nsView.stringValue != text { nsView.stringValue = text }
    }
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: NumericField
        init(_ parent: NumericField) { self.parent = parent }
        func controlTextDidChange(_ obj: Notification) {
            if let field = obj.object as? NSTextField {
                parent.text = field.stringValue
            }
        }
    }
}

// MARK: - 垂直居中 Cell
class VerticallyCenteredTextFieldCell: NSTextFieldCell {
    private func centeredRect(forBounds rect: NSRect) -> NSRect {
        let cellSize = cellSize(forBounds: rect)
        let offsetY = (rect.height - cellSize.height) / 2
        return NSRect(x: rect.origin.x, y: rect.origin.y + offsetY,
                      width: rect.width, height: cellSize.height)
    }
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        centeredRect(forBounds: rect)
    }
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        super.select(withFrame: centeredRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        super.edit(withFrame: centeredRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
    }
}

class StyledTextField: NSTextField {
    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    private func setup() {
        font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        textColor = .white
        drawsBackground = true
        backgroundColor = NSColor.white.withAlphaComponent(0.06)
        isBordered = false
        isBezeled = false
        focusRingType = .none
        alignment = .center
        wantsLayer = true
        layer?.cornerRadius = 5
        layer?.masksToBounds = true
        // 使用自定义 Cell 实现垂直居中
        let cell = VerticallyCenteredTextFieldCell()
        cell.font = font
        cell.textColor = .white
        cell.alignment = .center
        cell.isBezeled = false
        cell.isBordered = false
        cell.drawsBackground = true
        cell.backgroundColor = .clear
        cell.isEditable = true
        cell.focusRingType = .none
        self.cell = cell
    }
    override func draw(_ dirtyRect: NSRect) {
        let isFocused = window?.firstResponder is NSText
        NSColor.white.withAlphaComponent(isFocused ? 0.12 : 0.06).setFill()
        let path = NSBezierPath(roundedRect: bounds, xRadius: 5, yRadius: 5)
        path.fill()
        NSColor.white.withAlphaComponent(isFocused ? 0.25 : 0.1).setStroke()
        path.lineWidth = isFocused ? 0.8 : 0.5
        path.stroke()
        super.draw(dirtyRect)
    }
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result { needsDisplay = true }
        return result
    }
    override func resignFirstResponder() -> Bool {
        needsDisplay = true
        return super.resignFirstResponder()
    }
}

// ============================================================
// MARK: - 捕获覆盖层
// ============================================================
class CaptureOverlay {
    static private var globalMonitor: Any?
    static private var localMonitor: Any?
    static private var callback: ((Int, Int) -> Void)?
    static private var cancelled: (() -> Void)?
    static private(set) var isActive = false

    static func show(onClick: @escaping (Int, Int) -> Void,
                     cancelled: @escaping () -> Void) {
        guard !isActive else { return }
        isActive = true
        self.callback = onClick
        self.cancelled = cancelled

        // 全局监听：捕获其他应用窗口的点击
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { event in
            let loc = event.locationInWindow
            let screenH = (NSScreen.screens.first ?? NSScreen.main)?.frame.height ?? 0
            let x = Int(round(loc.x))
            let y = Int(round(screenH - loc.y))
            handleClick(x: x, y: y)
        }

        // 本地监听：点击面板时取消捕获
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { event in
            CaptureOverlay.handleEscape()
            return nil
        }
    }

    static func handleEscape() {
        let cb = cancelled
        cleanup()
        DispatchQueue.main.async { cb?() }
    }

    static private func handleClick(x: Int, y: Int) {
        let cb = callback
        cleanup()
        DispatchQueue.main.async { cb?(x, y) }
    }

    static private func cleanup() {
        if let m = globalMonitor { NSEvent.removeMonitor(m) }
        if let m = localMonitor { NSEvent.removeMonitor(m) }
        globalMonitor = nil
        localMonitor = nil
        isActive = false
    }
}

// ============================================================
// MARK: - App
// ============================================================
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var localEscMonitor: Any?
    private var globalEscMonitor: Any?
    private let vm = AppViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView(vm: vm)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 260, height: 264),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "模拟点击"
        window.isOpaque = false
        window.backgroundColor = NSColor(red: 0.08, green: 0.06, blue: 0.14, alpha: 0.55)
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.center()

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 264))

        let visualEffect = NSVisualEffectView(frame: container.bounds)
        visualEffect.autoresizingMask = [.width, .height]
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        container.addSubview(visualEffect)

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = container.bounds
        hostingView.autoresizingMask = [.width, .height] as NSView.AutoresizingMask
        container.addSubview(hostingView)

        window.contentView = container

        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { _ in
            if CaptureOverlay.isActive {
                CaptureOverlay.handleEscape()
            }
            NSApp.terminate(nil)
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        localEscMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 {
                if CaptureOverlay.isActive {
                    CaptureOverlay.handleEscape()
                } else if self.vm.isRunning {
                    self.vm.stop()
                }
            }
            return event
        }
        globalEscMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 {
                if CaptureOverlay.isActive {
                    CaptureOverlay.handleEscape()
                } else if self.vm.isRunning {
                    self.vm.stop()
                }
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}

// ============================================================
// MARK: - 入口
// ============================================================
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
