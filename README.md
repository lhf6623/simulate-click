# 模拟点击

Mac 平台鼠标模拟点击工具，适用于需要固定位置重复点击的场景。

## 特性

- 固定屏幕坐标位置重复点击
- 随机或固定点击间隔
- 多屏幕支持
- 全局 `Esc` 快捷键停止
- 磨砂玻璃风格 UI

## 安装

```bash
npm install
```

> 国内网络可配置镜像：`export ELECTRON_MIRROR="https://npmmirror.com/mirrors/electron/"`

## 运行

```bash
npm start
```

首次使用需授予**辅助功能权限**：系统设置 > 隐私与安全性 > 辅助功能。

## 使用

1. 点击 **捕获** 按钮，在目标位置点击鼠标获取坐标
2. 设置点击间隔（最小 ~ 最大，相等为固定间隔，不等为随机）
3. 设置点击次数（0 为不限）
4. 点击 **开始**，按 `Esc` 停止

## 打包

```bash
npm run pack   # 生成 .app
npm run dist   # 生成 .dmg
```

## 技术栈

- Electron + HTML/CSS
- Swift（CGEvent 后台点击）
- robotjs（辅助功能检测）
