import { create } from 'zustand'

export type Resolution = '3840x2160' | '2560x1440' | '1920x1080'

interface AppState {
  // UI State
  isAutoClickEnabled: boolean
  currentResolution: Resolution
  isRecipeSearchOpen: boolean
  isSettingsOpen: boolean
  currentTime: string

  // Actions
  setAutoClickEnabled: (enabled: boolean) => void
  setCurrentResolution: (resolution: Resolution) => void
  setRecipeSearchOpen: (open: boolean) => void
  setSettingsOpen: (open: boolean) => void
  updateTime: () => void
  handleHotkey: (hotkey: string) => void
}

export const useAppStore = create<AppState>((set, get) => ({
  // Initial state
  isAutoClickEnabled: false,
  currentResolution: '3840x2160',
  isRecipeSearchOpen: false,
  isSettingsOpen: false,
  currentTime: new Date().toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: true
  }),

  // Actions
  setAutoClickEnabled: (enabled) => {
    set({ isAutoClickEnabled: enabled })
    if (window.electronAPI) {
      window.electronAPI.toggleAutoClick(enabled)
    }
  },

  setCurrentResolution: (resolution) => {
    set({ currentResolution: resolution })
    if (window.electronAPI) {
      window.electronAPI.setResolution(resolution)
    }
  },

  setRecipeSearchOpen: (open) => set({ isRecipeSearchOpen: open }),

  setSettingsOpen: (open) => set({ isSettingsOpen: open }),

  updateTime: () => {
    const currentTime = new Date().toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: true
    })
    set({ currentTime })
  },

  handleHotkey: (hotkey) => {
    const state = get()

    switch (hotkey) {
      case 'F1':
        console.log('Depo action triggered')
        // Trigger depo automation
        break

      case 'F2':
        console.log('Loot Output action triggered')
        // Trigger loot output automation
        break

      case 'F3':
        console.log('Loot Input action triggered')
        // Trigger loot input automation
        break

      case 'F4':
        set({ isRecipeSearchOpen: !state.isRecipeSearchOpen })
        break

      case 'F5':
        set({ isSettingsOpen: !state.isSettingsOpen })
        break

      case 'F6':
        const newState = !state.isAutoClickEnabled
        set({ isAutoClickEnabled: newState })
        if (window.electronAPI) {
          window.electronAPI.toggleAutoClick(newState)
        }
        break

      default:
        console.log(`Unknown hotkey: ${hotkey}`)
    }
  }
}))
