import { contextBridge, ipcRenderer } from 'electron'

// Expose protected methods that allow the renderer process to use
// ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  // Resolution management
  setResolution: (resolution: string) => ipcRenderer.invoke('set-resolution', resolution),
  getScreenResolution: () => ipcRenderer.invoke('get-screen-resolution'),

  // Auto-click functionality
  toggleAutoClick: (enabled: boolean) => ipcRenderer.invoke('toggle-auto-click', enabled),
  onAutoClickTick: (callback: () => void) => {
    ipcRenderer.on('auto-click-tick', callback)
  },

  // Recipe search
  searchRecipe: (query: string) => ipcRenderer.invoke('search-recipe', query),

  // Hotkey handlers
  onHotkeyPressed: (callback: (hotkey: string) => void) => {
    ipcRenderer.on('hotkey-pressed', (event, hotkey) => callback(hotkey))
  },

  // Window controls
  minimizeWindow: () => ipcRenderer.send('minimize-window'),
  closeWindow: () => ipcRenderer.send('close-window'),
  toggleWindow: () => ipcRenderer.send('toggle-window'),

  // App info
  getAppVersion: () => ipcRenderer.invoke('get-app-version'),

  // Platform info
  platform: process.platform,
})

// Define types for TypeScript
export type ElectronAPI = {
  setResolution: (resolution: string) => Promise<{ success: boolean; resolution: string }>
  getScreenResolution: () => Promise<{ width: number; height: number }>
  toggleAutoClick: (enabled: boolean) => Promise<{ success: boolean; enabled: boolean }>
  onAutoClickTick: (callback: () => void) => void
  searchRecipe: (query: string) => Promise<any[]>
  onHotkeyPressed: (callback: (hotkey: string) => void) => void
  minimizeWindow: () => void
  closeWindow: () => void
  toggleWindow: () => void
  getAppVersion: () => Promise<string>
  platform: string
}

declare global {
  interface Window {
    electronAPI: ElectronAPI
  }
}
