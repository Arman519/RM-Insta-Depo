import { useEffect } from 'react'
import { useAppStore } from './store/useAppStore'
import Overlay from './components/Overlay'
import RecipeSearch from './components/RecipeSearch'
import Settings from './components/Settings'

function App() {
  const { updateTime, handleHotkey, isRecipeSearchOpen, isSettingsOpen } = useAppStore()

  useEffect(() => {
    // Update clock every second
    const clockInterval = setInterval(() => {
      updateTime()
    }, 1000)

    // Set up hotkey listener
    if (window.electronAPI) {
      window.electronAPI.onHotkeyPressed((hotkey) => {
        handleHotkey(hotkey)
      })
    }

    return () => {
      clearInterval(clockInterval)
    }
  }, [updateTime, handleHotkey])

  return (
    <div className="w-full h-full">
      {/* Main Overlay */}
      <Overlay />

      {/* Recipe Search Modal */}
      {isRecipeSearchOpen && <RecipeSearch />}

      {/* Settings Modal */}
      {isSettingsOpen && <Settings />}
    </div>
  )
}

export default App
