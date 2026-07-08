# 模拟点击

Mac 平台鼠标模拟点击工具，适用于需要固定位置重复点击的场景。

## 特性

- 固定屏幕坐标位置重复点击
- 随机或固定点击间隔（最小 ~ 最大毫秒）
- 多屏幕支持
- 全局 `Esc` 快捷键停止
- 磨砂玻璃风格 UI（HUD 浮动窗口）
- 点击次数实时统计

## 环境要求

- macOS 13.0+
- Swift 5.9+（Xcode 15 或 Command Line Tools）

## 运行

```bash
swift run SimulateClickApp
```

首次使用需授予**辅助功能权限**：系统设置 > 隐私与安全性 > 辅助功能。

## 使用

1. 在**位置**栏点击**捕获**，在目标位置点击鼠标获取坐标（点击面板取消捕获）
2. 设置**间隔**（最小 ~ 最大，相等为固定间隔，不等为随机间隔）
3. 设置**点击次数**（0 为不限）
4. 点击**开始**，按 `Esc` 停止

## 打包

```bash
bash build-app.sh
```

产物输出到 `dist/` 目录：

| 产物 | 说明 |
|------|------|
| `模拟点击.app` | 可直接运行的 macOS 应用包 |
| `模拟点击.dmg` | 安装镜像，含 Applications 快捷方式 |

## CI/CD

推送 `v*` 标签自动构建并发布 GitHub Release：

```bash
git tag v1.0.0
git push origin v1.0.0
```

## 测试

```bash
swift test
```

## 技术栈

- **Swift + SwiftUI** — 纯原生实现，零外部依赖
- **CGEvent** — 后台模拟鼠标点击（不影响光标位置）
- **NSEvent** — 全局/本地事件监听（坐标捕获、快捷键）

## 项目结构

```
Sources/
├── SimulateClickApp/        # UI 层（SwiftUI + AppKit）
│   └── main.swift
└── SimulateClickCore/       # 业务逻辑层
    ├── AppViewModel.swift
    ├── ClickEngine.swift
    └── SystemPermissionChecker.swift
Tests/
└── SimulateClickCoreTests/  # 单元测试
```
