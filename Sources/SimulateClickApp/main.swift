import SwiftUI
import AppKit
import SimulateClickCore

// ============================================================
// MARK: - 主题配色
// ============================================================
struct Theme {
    let isDark: Bool
    // 卡片
    let cardBackground: Color
    let cardBorder: Color
    let cardCornerRadius: CGFloat
    let cardBorderWidth: CGFloat
    let cardPadding: CGFloat
    // 文字
    let textPrimary: Color
    let textSecondary: Color
    let labelOpacity: CGFloat          // X/Y 标签
    let separatorOpacity: CGFloat      // ~ 分隔符
    let statusDotIdleOpacity: CGFloat  // 状态圆点空闲
    let statusDotGlowOpacity: CGFloat  // 状态圆点光晕
    let statusTextOpacity: CGFloat     // 状态文字
    // 输入框
    let inputBackground: NSColor
    let inputBorder: NSColor
    let inputBgAlpha: (focused: CGFloat, normal: CGFloat)
    let inputBorderAlpha: (focused: CGFloat, normal: CGFloat)
    let inputBorderWidth: (focused: CGFloat, normal: CGFloat)
    let cornerRadius: CGFloat
    let inputFont: NSFont
    // 迷你按钮
    let miniButtonBg: Color
    let miniButtonBorder: Color
    let miniButtonCornerRadius: CGFloat
    let miniButtonPressedBgOpacity: CGFloat
    let miniButtonHoverBgOpacity: CGFloat
    let miniButtonPressedBorderOpacity: CGFloat
    let miniButtonHoverBorderOpacity: CGFloat
    let miniButtonTextOpacity: CGFloat
    // 操作按钮
    let actionButtonCornerRadius: CGFloat
    let actionButtonBgOpacity: (pressed: CGFloat, hover: CGFloat, normal: CGFloat)
    let actionButtonBorderOpacity: (pressed: CGFloat, hover: CGFloat, normal: CGFloat)
    // 窗口
    let windowBackground: NSColor

    var nsTextColor: NSColor { isDark ? .white : .black }

    static let light = Theme(
        isDark: false,
        cardBackground: Color(red: 0.98, green: 0.98, blue: 0.99),
        cardBorder: Color(red: 0.88, green: 0.88, blue: 0.90),
        cardCornerRadius: 8,
        cardBorderWidth: 0.5,
        cardPadding: 8,
        textPrimary: Color(red: 0.11, green: 0.11, blue: 0.13),
        textSecondary: Color(red: 0.42, green: 0.42, blue: 0.48),
        labelOpacity: 0.7,
        separatorOpacity: 0.4,
        statusDotIdleOpacity: 0.4,
        statusDotGlowOpacity: 0.6,
        statusTextOpacity: 0.8,
        inputBackground: NSColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1.0),
        inputBorder: NSColor(red: 0.80, green: 0.80, blue: 0.84, alpha: 1.0),
        inputBgAlpha: (0.85, 0.65),
        inputBorderAlpha: (0.9, 0.5),
        inputBorderWidth: (0.8, 0.5),
        cornerRadius: 8,
        inputFont: .systemFont(ofSize: 14, weight: .regular),
        miniButtonBg: Color(red: 0.93, green: 0.93, blue: 0.95),
        miniButtonBorder: Color(red: 0.80, green: 0.80, blue: 0.84),
        miniButtonCornerRadius: 5,
        miniButtonPressedBgOpacity: 0.7,
        miniButtonHoverBgOpacity: 1.0,
        miniButtonPressedBorderOpacity: 0.8,
        miniButtonHoverBorderOpacity: 1.0,
        miniButtonTextOpacity: 0.8,
        actionButtonCornerRadius: 7,
        actionButtonBgOpacity: (0.5, 0.85, 0.75),
        actionButtonBorderOpacity: (0.3, 0.5, 0.4),
        windowBackground: NSColor(white: 0.93, alpha: 0.92)
    )

    static let dark = Theme(
        isDark: true,
        cardBackground: Color(red: 0.11, green: 0.11, blue: 0.14),
        cardBorder: Color(red: 0.22, green: 0.22, blue: 0.28),
        cardCornerRadius: 8,
        cardBorderWidth: 0.5,
        cardPadding: 8,
        textPrimary: Color.white,
        textSecondary: Color(red: 0.60, green: 0.60, blue: 0.66),
        labelOpacity: 0.7,
        separatorOpacity: 0.4,
        statusDotIdleOpacity: 0.4,
        statusDotGlowOpacity: 0.6,
        statusTextOpacity: 0.8,
        inputBackground: NSColor(red: 0.35, green: 0.35, blue: 0.40, alpha: 1.0),
        inputBorder: NSColor(red: 0.45, green: 0.45, blue: 0.50, alpha: 1.0),
        inputBgAlpha: (0.9, 0.75),
        inputBorderAlpha: (0.8, 0.5),
        inputBorderWidth: (0.8, 0.5),
        cornerRadius: 8,
        inputFont: .systemFont(ofSize: 14, weight: .regular),
        miniButtonBg: Color(red: 0.17, green: 0.17, blue: 0.21),
        miniButtonBorder: Color(red: 0.30, green: 0.30, blue: 0.36),
        miniButtonCornerRadius: 5,
        miniButtonPressedBgOpacity: 0.7,
        miniButtonHoverBgOpacity: 1.0,
        miniButtonPressedBorderOpacity: 0.8,
        miniButtonHoverBorderOpacity: 1.0,
        miniButtonTextOpacity: 0.8,
        actionButtonCornerRadius: 7,
        actionButtonBgOpacity: (0.5, 0.85, 0.75),
        actionButtonBorderOpacity: (0.3, 0.5, 0.4),
        windowBackground: NSColor(white: 0.08, alpha: 0.92)
    )
}

// ============================================================
// MARK: - SwiftUI 主界面
// ============================================================
struct ContentView: View {
    @ObservedObject var vm: AppViewModel
    var colorScheme: ColorScheme = .light

    var theme: Theme { colorScheme == .dark ? .dark : .light }

    var body: some View {
        let _ = print("[ContentView] body rendered, colorScheme: \(colorScheme), isDark: \(theme.isDark)")
        VStack(spacing: 6) {
            // 点击次数
            card {
                sectionHeader("点击次数 (0为不限)", status: vm.isRunning ? "运行中" : "空闲", running: vm.isRunning)
                NumericField(text: $vm.countLimitText, theme: theme)
                    .frame(height: 28)
            }

            // 位置
            card {
                sectionHeader("位置")
                HStack(spacing: 5) {
                    Text("X").font(.system(size: 12, weight: .medium)).foregroundColor(theme.textSecondary.opacity(theme.labelOpacity)).frame(width: 14)
                    NumericField(text: $vm.posXText, theme: theme)
                    Text("Y").font(.system(size: 12, weight: .medium)).foregroundColor(theme.textSecondary.opacity(theme.labelOpacity)).frame(width: 14)
                    NumericField(text: $vm.posYText, theme: theme)
                    MiniButton(title: "捕获", isWaiting: vm.isCapturing, theme: theme) {
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
                }
            }

            // 间隔
            card {
                sectionHeader("间隔 (毫秒)")
                HStack(spacing: 5) {
                    NumericField(text: $vm.minDelayText, theme: theme)
                    Text("~").font(.system(size: 14)).foregroundColor(theme.textSecondary.opacity(theme.separatorOpacity))
                    NumericField(text: $vm.maxDelayText, theme: theme)
                }
            }

            // 开始/停止按钮
            if !vm.isRunning {
                ActionButton(title: "开始", color: .green, textColor: theme.textPrimary, theme: theme) { vm.start() }
                    .frame(height: 32)
            } else {
                ActionButton(title: "停止 (Esc)  ·  已点击 \(vm.clickCount) 次", color: .red, textColor: theme.textPrimary, theme: theme) { vm.stop() }
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
        .padding(theme.cardPadding)
        .background(theme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: theme.cardCornerRadius)
                .stroke(theme.cardBorder, lineWidth: theme.cardBorderWidth)
        )
        .cornerRadius(theme.cardCornerRadius)
    }

    @ViewBuilder
    func sectionHeader(_ label: String, status: String? = nil, running: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.textSecondary)
            Spacer()
            if let status {
                HStack(spacing: 3) {
                    Circle()
                        .fill(running ? Color.green : theme.textSecondary.opacity(theme.statusDotIdleOpacity))
                        .frame(width: 5, height: 5)
                        .shadow(color: running ? .green.opacity(theme.statusDotGlowOpacity) : .clear, radius: 2)
                    Text(status)
                        .font(.system(size: 13))
                        .foregroundColor(theme.textSecondary.opacity(theme.statusTextOpacity))
                }
            }
        }
    }
}

// ============================================================
// MARK: - 按钮样式
// ============================================================
struct MiniButton: View {
    let title: String
    var isWaiting = false
    var theme: Theme = .light
    var action: () -> Void
    @State private var isHovering = false
    @State private var isPressed = false

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isWaiting ? .yellow : theme.textPrimary.opacity(theme.miniButtonTextOpacity))
            .frame(width: 52, height: 28)
            .background(background)
            .overlay(RoundedRectangle(cornerRadius: theme.miniButtonCornerRadius).stroke(border, lineWidth: 0.5))
            .cornerRadius(theme.miniButtonCornerRadius)
            .onHover { isHovering = $0 }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false; action() })
    }

    private var background: Color {
        if isWaiting { return Color.yellow.opacity(0.15) }
        if isPressed { return theme.miniButtonBg.opacity(theme.miniButtonPressedBgOpacity) }
        if isHovering { return theme.miniButtonBg.opacity(theme.miniButtonHoverBgOpacity) }
        return theme.miniButtonBg
    }

    private var border: Color {
        if isWaiting { return Color.yellow.opacity(0.4) }
        if isPressed { return theme.miniButtonBorder.opacity(theme.miniButtonPressedBorderOpacity) }
        if isHovering { return theme.miniButtonBorder.opacity(theme.miniButtonHoverBorderOpacity) }
        return theme.miniButtonBorder
    }
}

struct ActionButton: View {
    let title: String
    let color: Color
    var textColor: Color = .white
    var theme: Theme = .light
    var action: () -> Void
    @State private var isHovering = false
    @State private var isPressed = false

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color.opacity(bgOpacity))
            .overlay(RoundedRectangle(cornerRadius: theme.actionButtonCornerRadius).stroke(color.opacity(borderOpacity), lineWidth: 0.5))
            .cornerRadius(theme.actionButtonCornerRadius)
            .onHover { isHovering = $0 }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false; action() })
    }

    private var bgOpacity: Double {
        if isPressed { return Double(theme.actionButtonBgOpacity.pressed) }
        if isHovering { return Double(theme.actionButtonBgOpacity.hover) }
        return Double(theme.actionButtonBgOpacity.normal)
    }

    private var borderOpacity: Double {
        if isPressed { return Double(theme.actionButtonBorderOpacity.pressed) }
        if isHovering { return Double(theme.actionButtonBorderOpacity.hover) }
        return Double(theme.actionButtonBorderOpacity.normal)
    }
}

// ============================================================
// MARK: - 数字输入框
// ============================================================
struct NumericField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var theme: Theme = .light

    func makeNSView(context: Context) -> StyledTextField {
        let field = StyledTextField(theme: theme)
        field.delegate = context.coordinator
        field.heightAnchor.constraint(equalToConstant: 28).isActive = true
        field.placeholderString = placeholder.isEmpty ? nil : placeholder
        return field
    }
    func updateNSView(_ nsView: StyledTextField, context: Context) {
        if nsView.stringValue != text { nsView.stringValue = text }
        nsView.applyTheme(self.theme)  // self 是当前最新的 NumericField，包含最新 theme
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
    private var theme: Theme

    init(theme: Theme = .light) {
        self.theme = theme
        super.init(frame: .zero)
        setup()
    }
    required init?(coder: NSCoder) {
        self.theme = .light
        super.init(coder: coder)
        setup()
    }
    func applyTheme(_ newTheme: Theme) {
        print("[StyledTextField] applyTheme called, old isDark: \(theme.isDark), new isDark: \(newTheme.isDark)")
        guard newTheme.isDark != theme.isDark else { print("[StyledTextField] same isDark, skipping"); return }
        theme = newTheme
        font = theme.inputFont
        textColor = theme.nsTextColor
        layer?.cornerRadius = theme.cornerRadius
        if let cell = cell as? VerticallyCenteredTextFieldCell {
            cell.font = font
            cell.textColor = textColor
        }
        needsDisplay = true
    }
    private func setup() {
        font = theme.inputFont
        textColor = theme.nsTextColor
        drawsBackground = false  // 由 draw() 自定义绘制，避免双层叠加
        isBordered = false
        isBezeled = false
        focusRingType = .none
        alignment = .center
        wantsLayer = true
        layer?.cornerRadius = theme.cornerRadius
        layer?.masksToBounds = true
        let cell = VerticallyCenteredTextFieldCell()
        cell.font = font
        cell.textColor = textColor
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
        theme.inputBackground.withAlphaComponent(isFocused ? theme.inputBgAlpha.focused : theme.inputBgAlpha.normal).setFill()
        let r = theme.cornerRadius
        let path = NSBezierPath(roundedRect: bounds, xRadius: r, yRadius: r)
        path.fill()
        theme.inputBorder.withAlphaComponent(isFocused ? theme.inputBorderAlpha.focused : theme.inputBorderAlpha.normal).setStroke()
        path.lineWidth = isFocused ? theme.inputBorderWidth.focused : theme.inputBorderWidth.normal
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
    private var hostingView: NSHostingView<ContentView>!
    private var localEscMonitor: Any?
    private var globalEscMonitor: Any?
    private var appearanceObserver: NSKeyValueObservation?
    private let vm = AppViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView(vm: vm, colorScheme: currentColorScheme())

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 260, height: 264),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "模拟点击"
        window.isOpaque = false
        updateWindowBackground()
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.center()

        let container = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 264))

        let visualEffect = NSVisualEffectView(frame: container.bounds)
        visualEffect.autoresizingMask = [.width, .height]
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .withinWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        container.addSubview(visualEffect)

        hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = container.bounds
        hostingView.autoresizingMask = [.width, .height] as NSView.AutoresizingMask
        container.addSubview(hostingView)

        window.contentView = container

        // KVO 监听窗口外观变化
        appearanceObserver = window.observe(\.effectiveAppearance, options: [.new]) { [weak self] _, change in
            print("[KVO] effectiveAppearance changed: \(change.newValue?.name.rawValue ?? "nil")")
            DispatchQueue.main.async { self?.onThemeChanged() }
        }
        print("[Init] KVO observer set up, initial appearance: \(window.effectiveAppearance.name.rawValue)")
        print("[Init] initial colorScheme: \(currentColorScheme())")

        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { [weak self] _ in
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

    private func currentColorScheme() -> ColorScheme {
        let name = NSApp.effectiveAppearance.name.rawValue
        let result: ColorScheme = name.contains("Dark") ? .dark : .light
        print("[currentColorScheme] appearance name: \(name) -> \(result)")
        return result
    }

    private func onThemeChanged() {
        print("[Theme] === onThemeChanged START ===")
        let scheme = currentColorScheme()
        print("[Theme] updating window bg + rootView to scheme: \(scheme)")
        updateWindowBackground()
        hostingView.rootView = ContentView(vm: vm, colorScheme: scheme)
        print("[Theme] === onThemeChanged END ===")
    }

    private func updateWindowBackground() {
        let isDark = NSApp.effectiveAppearance.name.rawValue.contains("Dark")
        window.backgroundColor = (isDark ? Theme.dark : Theme.light).windowBackground
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
