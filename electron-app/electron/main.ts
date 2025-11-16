import { app, BrowserWindow, ipcMain, screen, globalShortcut } from 'electron'
import path from 'path'

// Keep a global reference of the window object
let mainWindow: BrowserWindow | null = null
let overlayWindow: BrowserWindow | null = null

// Development mode check
const isDev = process.env.NODE_ENV === 'development' || !app.isPackaged

function createOverlayWindow() {
  // Get primary display dimensions
  const primaryDisplay = screen.getPrimaryDisplay()
  const { width, height } = primaryDisplay.workAreaSize

  overlayWindow = new BrowserWindow({
    width: 200,
    height: 240,
    x: 50,
    y: 50,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    resizable: false,
    skipTaskbar: true,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  })

  // Load the overlay window
  if (isDev) {
    overlayWindow.loadURL('http://localhost:5173')
    overlayWindow.webContents.openDevTools({ mode: 'detach' })
  } else {
    overlayWindow.loadFile(path.join(__dirname, '../dist/index.html'))
  }

  // Make window draggable
  overlayWindow.setIgnoreMouseEvents(false)

  overlayWindow.on('closed', () => {
    overlayWindow = null
  })
}

function createMainWindow() {
  mainWindow = new BrowserWindow({
    width: 400,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    },
    show: false // Hidden by default, overlay is main UI
  })

  if (isDev) {
    mainWindow.loadURL('http://localhost:5173')
  } else {
    mainWindow.loadFile(path.join(__dirname, '../dist/index.html'))
  }

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

app.whenReady().then(() => {
  createOverlayWindow()
  createMainWindow()

  // Register global hotkeys
  registerHotkeys()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createOverlayWindow()
      createMainWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('will-quit', () => {
  // Unregister all shortcuts
  globalShortcut.unregisterAll()
})

// ============================================================================
// HOTKEY REGISTRATION
// ============================================================================

function registerHotkeys() {
  // F1 - Depo
  globalShortcut.register('F1', () => {
    overlayWindow?.webContents.send('hotkey-pressed', 'F1')
  })

  // F2 - Loot Output
  globalShortcut.register('F2', () => {
    overlayWindow?.webContents.send('hotkey-pressed', 'F2')
  })

  // F3 - Loot Input
  globalShortcut.register('F3', () => {
    overlayWindow?.webContents.send('hotkey-pressed', 'F3')
  })

  // F4 - Recipe Search
  globalShortcut.register('F4', () => {
    overlayWindow?.webContents.send('hotkey-pressed', 'F4')
  })

  // F5 - Select Resolution
  globalShortcut.register('F5', () => {
    overlayWindow?.webContents.send('hotkey-pressed', 'F5')
  })

  // F6 - Toggle Auto Click
  globalShortcut.register('F6', () => {
    overlayWindow?.webContents.send('hotkey-pressed', 'F6')
  })

  // F8 - Show/Hide Overlay
  globalShortcut.register('F8', () => {
    if (overlayWindow) {
      if (overlayWindow.isVisible()) {
        overlayWindow.hide()
      } else {
        overlayWindow.show()
      }
    }
  })
}

// ============================================================================
// IPC HANDLERS
// ============================================================================

// Handle resolution change
ipcMain.handle('set-resolution', async (event, resolution: string) => {
  console.log(`Resolution changed to: ${resolution}`)
  // Store resolution preference
  return { success: true, resolution }
})

// Handle auto-click toggle
let autoClickInterval: NodeJS.Timeout | null = null

ipcMain.handle('toggle-auto-click', async (event, enabled: boolean) => {
  if (enabled) {
    // Start auto-clicking
    autoClickInterval = setInterval(() => {
      overlayWindow?.webContents.send('auto-click-tick')
    }, 500)
    return { success: true, enabled: true }
  } else {
    // Stop auto-clicking
    if (autoClickInterval) {
      clearInterval(autoClickInterval)
      autoClickInterval = null
    }
    return { success: true, enabled: false }
  }
})

// Handle recipe search
ipcMain.handle('search-recipe', async (event, query: string) => {
  // Import recipe database
  const { searchRecipes } = require('./recipes')
  const results = searchRecipes(query)
  return results
})

// Get screen resolution
ipcMain.handle('get-screen-resolution', async () => {
  const primaryDisplay = screen.getPrimaryDisplay()
  const { width, height } = primaryDisplay.size
  return { width, height }
})

// Window controls
ipcMain.on('minimize-window', () => {
  overlayWindow?.minimize()
})

ipcMain.on('close-window', () => {
  app.quit()
})

ipcMain.on('toggle-window', () => {
  if (overlayWindow) {
    if (overlayWindow.isVisible()) {
      overlayWindow.hide()
    } else {
      overlayWindow.show()
    }
  }
})

// Get app version
ipcMain.handle('get-app-version', () => {
  return app.getVersion()
})

console.log('Electron main process started')
