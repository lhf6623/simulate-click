const { app, BrowserWindow, ipcMain, globalShortcut, dialog, screen } = require('electron');
const robot = require('@jitsi/robotjs');
const path = require('path');
const { spawn } = require('child_process');

let mainWindow;
let clickInterval = null;
let isClicking = false;
let clickCount = 0;
let bgClickProcess = null;
let bgClickReady = false;
let clickConfig = {
  countLimit: 1,
  x: 0,
  y: 0,
  minDelay: 500,
  maxDelay: 1500
};

// 获取资源路径（开发时用 __dirname，打包后用 process.resourcesPath）
function getResourcePath(filename) {
  return path.join(app.isPackaged ? process.resourcesPath : __dirname, filename);
}

// 启动后台点击进程
function startBgClickProcess() {
  if (bgClickProcess) return;
  const bgClickPath = getResourcePath('bg_click');
  bgClickProcess = spawn(bgClickPath, [], { stdio: ['pipe', 'pipe', 'pipe'] });
  bgClickReady = false;
  bgClickProcess.stdout.on('data', (data) => {
    const msg = data.toString().trim();
    if (msg === 'ready') bgClickReady = true;
    else console.log('bg_click:', msg);
  });
  bgClickProcess.stderr.on('data', (data) => {
    console.error('bg_click err:', data.toString());
  });
  bgClickProcess.on('exit', (code) => {
    bgClickProcess = null;
    bgClickReady = false;
    // 如果正在点击中进程挂了，停止并通知
    if (isClicking) {
      isClicking = false;
      if (clickInterval) { clearTimeout(clickInterval); clickInterval = null; }
      updateEscShortcut();
      if (mainWindow && !mainWindow.isDestroyed()) {
        mainWindow.webContents.send('click-stopped', { reason: 'error', count: clickCount });
      }
    }
  });
}

function bgClick(x, y) {
  if (bgClickProcess && bgClickProcess.stdin && !bgClickProcess.killed) {
    bgClickProcess.stdin.write(`click ${x} ${y}\n`);
  }
}

function stopBgClickProcess() {
  if (bgClickProcess) {
    try { bgClickProcess.stdin.write('quit\n'); } catch (e) {}
    try { bgClickProcess.stdin.end(); } catch (e) {}
    // 确保进程被终止
    setTimeout(() => {
      try { if (bgClickProcess && !bgClickProcess.killed) bgClickProcess.kill(); } catch (e) {}
    }, 500);
    bgClickProcess = null;
    bgClickReady = false;
  }
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 280,
    height: 310,
    resizable: false,
    alwaysOnTop: true,
    title: '',
    transparent: true,
    frame: false,
    hasShadow: false,
    vibrancy: 'hud',
    visualEffectState: 'active',
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    },
    icon: path.join(__dirname, 'icon.png')
  });

  mainWindow.loadFile('index.html');
  mainWindow.setMenu(null);
}

function checkAccessibilityPermission() {
  try {
    const mousePos = robot.getMousePos();
    return true;
  } catch (e) {
    return false;
  }
}

function getNextDelay() {
  if (clickConfig.minDelay === clickConfig.maxDelay) {
    return clickConfig.minDelay;
  }
  return Math.random() * (clickConfig.maxDelay - clickConfig.minDelay) + clickConfig.minDelay;
}

function simulateClick() {
  if (!isClicking) return;

  // 通过 bg_click 进程点击（使用 CGWarpMouseCursorPosition，坐标准确）
  bgClick(clickConfig.x, clickConfig.y);

  clickCount++;

  if (clickConfig.countLimit > 0 && clickCount >= clickConfig.countLimit) {
    stopClicking();
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.webContents.send('click-stopped', { reason: 'limit', count: clickCount });
    }
    return;
  }

  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send('click-update', clickCount);
  }

  const delay = getNextDelay();
  clickInterval = setTimeout(simulateClick, delay);
}

// 动态注册/注销 Esc 全局快捷键（按需，不用时释放给系统）
function updateEscShortcut() {
  globalShortcut.unregister('Escape');
  if (captureOverlays.length > 0) {
    globalShortcut.register('Escape', () => {
      if (captureEvent) {
        captureEvent.reply('capture-cancelled');
      }
      destroyCaptureOverlays();
    });
  } else if (isClicking) {
    globalShortcut.register('Escape', () => { stopClicking(); });
  }
}

// 请求辅助功能权限（弹出系统授权对话框，完成后回调）
function requestAccessibilityPermission(callback) {
  const checkPermPath = getResourcePath('check_perm');
  const proc = spawn(checkPermPath, [], { stdio: ['pipe', 'pipe', 'pipe'] });
  let output = '';
  proc.stdout.on('data', (data) => {
    output += data.toString().trim();
  });
  proc.on('exit', () => {
    const granted = output.includes('granted');
    if (callback) callback(granted);
  });
}

function startClicking() {
  if (isClicking) return;

  if (!checkAccessibilityPermission()) {
    requestAccessibilityPermission((granted) => {
      if (granted) {
        startClicking();
      } else {
        dialog.showMessageBox(mainWindow, {
          type: 'warning',
          title: '权限未授予',
          message: '未获得辅助功能权限，无法使用点击功能。\n\n请前往：系统设置 > 隐私与安全性 > 辅助功能\n找到本应用并开启权限后重试。',
          buttons: ['知道了']
        });
      }
    });
    return;
  }

  // 启动后台点击进程
  startBgClickProcess();
  let waitCount = 0;
  const waitInterval = setInterval(() => {
    waitCount++;
    if (bgClickReady || waitCount > 10) {
      clearInterval(waitInterval);
      doStartClicking();
    }
  }, 100);
}

function doStartClicking() {
  isClicking = true;
  clickCount = 0;
  mainWindow.webContents.send('click-started');
  updateEscShortcut();
  simulateClick();
}

function stopClicking() {
  isClicking = false;
  if (clickInterval) {
    clearTimeout(clickInterval);
    clickInterval = null;
  }
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send('click-stopped', { reason: 'manual', count: clickCount });
  }
  updateEscShortcut();
}

ipcMain.on('close-window', () => {
  app.quit();
});

ipcMain.on('start-click', () => {
  startClicking();
});

ipcMain.on('stop-click', () => {
  stopClicking();
});

ipcMain.on('update-config', (event, config) => {
  clickConfig = { ...clickConfig, ...config };
});

// 全屏透明覆盖层 - 每个屏幕一个窗口，支持多屏幕
let captureOverlays = [];
let captureEvent = null;

function destroyCaptureOverlays() {
  for (const w of captureOverlays) {
    try { w.destroy(); } catch (e) {}
  }
  captureOverlays = [];
  captureEvent = null;
  updateEscShortcut();
}

ipcMain.on('start-capture-overlay', (event) => {
  // 先检查权限，没权限时弹出系统授权对话框
  if (!checkAccessibilityPermission()) {
    requestAccessibilityPermission((granted) => {
      if (granted) {
        // 授权成功，重新触发
        doStartCapture(event);
      } else {
        event.reply('capture-cancelled');
      }
    });
    return;
  }
  doStartCapture(event);
});

function doStartCapture(event) {
  destroyCaptureOverlays();
  captureEvent = event;

  const allDisplays = screen.getAllDisplays();
  for (const d of allDisplays) {
    const overlay = new BrowserWindow({
      x: d.bounds.x, y: d.bounds.y,
      width: d.bounds.width, height: d.bounds.height,
      transparent: true,
      frame: false,
      alwaysOnTop: true,
      skipTaskbar: true,
      hasShadow: false,
      webPreferences: {
        nodeIntegration: true,
        contextIsolation: false
      }
    });
    overlay.loadFile('capture.html', { query: { ox: String(d.bounds.x), oy: String(d.bounds.y) } });
    overlay.setMenu(null);
    captureOverlays.push(overlay);
  }
  updateEscShortcut();
}

ipcMain.on('capture-clicked', () => {
  try {
    // 用 screen 模块获取鼠标位置（支持负坐标，robotjs 在第二屏幕 Y 总是 0）
    const cursorPoint = screen.getCursorScreenPoint();
    console.log('capture pos:', cursorPoint);
    if (captureEvent) {
      captureEvent.reply('mouse-pos', cursorPoint);
    }
  } catch (e) { console.error(e); }
  destroyCaptureOverlays();
});

ipcMain.on('capture-mousemove', (event) => {
  try {
    const cursorPoint = screen.getCursorScreenPoint();
    event.reply('capture-pos', cursorPoint);
  } catch (e) {}
});

ipcMain.on('capture-cancelled', () => {
  if (captureEvent) {
    captureEvent.reply('capture-cancelled');
  }
  destroyCaptureOverlays();
});

ipcMain.on('check-permission', (event) => {
  event.reply('permission-status', checkAccessibilityPermission());
});

// 请求辅助功能权限（从 UI 按钮触发，弹出系统授权对话框）
ipcMain.on('request-permission', (event) => {
  requestAccessibilityPermission((granted) => {
    event.reply('permission-status', granted);
    if (!granted) {
      dialog.showMessageBox(mainWindow, {
        type: 'warning',
        title: '权限未授予',
        message: '未获得辅助功能权限，部分功能可能无法正常使用。\n\n请前往：系统设置 > 隐私与安全性 > 辅助功能\n找到本应用并开启权限后重试。',
        buttons: ['知道了']
      });
    }
  });
});

app.whenReady().then(() => {
  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
  stopClicking();
  stopBgClickProcess();
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});
