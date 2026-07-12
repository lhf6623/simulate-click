#!/bin/bash
set -e

APP_NAME="模拟点击"
BUNDLE_ID="com.example.simulate-click"
BINARY_NAME="SimulateClickApp"
BUILD_DIR=".build/release"
OUT_DIR="dist"

# 版本号：优先环境变量（CI），否则读 VERSION 文件
APP_VERSION="${APP_VERSION:-$(cat VERSION 2>/dev/null || echo 0.0.0)}"
APP_VERSION="${APP_VERSION#v}"  # 去掉 v 前缀（如 v1.0.0 → 1.0.0）

APP_BUNDLE="${OUT_DIR}/${APP_NAME}.app"
ZIP_NAME="${OUT_DIR}/${APP_NAME}-${APP_VERSION}.zip"
DMG_NAME="${OUT_DIR}/${APP_NAME}-${APP_VERSION}.dmg"

echo "==> 编译 Release 版本..."
swift build -c release

echo "==> 构建 .app 包..."
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# 复制二进制
cp "${BUILD_DIR}/${BINARY_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# 复制图标
if [ -f "icon.icns" ]; then
    cp icon.icns "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
fi

# 生成 Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <false/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "==> 构建 ${DMG_NAME}..."
rm -f "${DMG_NAME}"

# 通过 sparse image + 挂载到 /tmp 创建 DMG（避免 -srcfolder 对 /Volumes 的依赖）
SPARSE_IMG="/tmp/${APP_NAME}-${APP_VERSION}.sparseimage"
MNT_POINT="/tmp/${APP_NAME}-mnt"
rm -rf "${SPARSE_IMG}" "${MNT_POINT}"
mkdir -p "${MNT_POINT}"
hdiutil create -type SPARSE -size 10m -volname "${APP_NAME}" -fs "HFS+" -ov "${SPARSE_IMG}" 2>/dev/null
hdiutil attach "${SPARSE_IMG}" -mountroot "${MNT_POINT}" -nobrowse 2>/dev/null
cp -R "${APP_BUNDLE}" "${MNT_POINT}/${APP_NAME}/"
ln -s /Applications "${MNT_POINT}/${APP_NAME}/Applications"
hdiutil detach "${MNT_POINT}/${APP_NAME}" 2>/dev/null
hdiutil convert "${SPARSE_IMG}" -format UDZO -o "${DMG_NAME}" 2>/dev/null
rm -rf "${SPARSE_IMG}" "${MNT_POINT}"

echo "==> 压缩 ${ZIP_NAME}..."
cd "${OUT_DIR}" && zip -r "$(basename "${ZIP_NAME}")" "$(basename "${APP_BUNDLE}")" -x "*.DS_Store" > /dev/null && cd - > /dev/null

echo "==> 完成 (v${APP_VERSION})"
echo "    .zip: $(du -sh "${ZIP_NAME}" | cut -f1)"
echo "    .dmg: $(du -sh "${DMG_NAME}" | cut -f1)"
echo "    运行: open ${APP_BUNDLE}"
echo "    分发: ${ZIP_NAME} / ${DMG_NAME}"
