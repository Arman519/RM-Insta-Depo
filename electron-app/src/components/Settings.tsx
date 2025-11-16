import { motion, AnimatePresence } from 'framer-motion'
import { useAppStore, Resolution } from '../store/useAppStore'
import clsx from 'clsx'

const Settings = () => {
  const { currentResolution, setCurrentResolution, setSettingsOpen } = useAppStore()

  const resolutions: { value: Resolution; label: string; icon: string }[] = [
    { value: '3840x2160', label: '3840 x 2160 (4K UHD)', icon: '🖥️' },
    { value: '2560x1440', label: '2560 x 1440 (QHD)', icon: '🖥️' },
    { value: '1920x1080', label: '1920 x 1080 (Full HD)', icon: '🖥️' },
  ]

  const handleResolutionChange = (resolution: Resolution) => {
    setCurrentResolution(resolution)
  }

  const handleApply = () => {
    setSettingsOpen(false)
  }

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50"
        onClick={() => setSettingsOpen(false)}
      >
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.9, opacity: 0 }}
          transition={{ type: 'spring', damping: 25 }}
          className="glass-elevated rounded-2xl shadow-2xl border border-ui-border/50 w-[90%] max-w-md p-6"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-2xl font-bold gradient-text flex items-center gap-2">
                ⚙️ Settings
              </h2>
              <p className="text-sm text-text-secondary mt-1">
                Configure your preferences
              </p>
            </div>
            <button
              onClick={() => setSettingsOpen(false)}
              className="text-text-tertiary hover:text-text-primary transition-colors"
            >
              <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Screen Resolution */}
          <div className="space-y-4">
            <div>
              <h3 className="text-lg font-semibold text-text-primary mb-2">
                Screen Resolution
              </h3>
              <p className="text-sm text-text-secondary mb-4">
                Choose the resolution that matches your display
              </p>

              <div className="space-y-3">
                {resolutions.map((resolution) => (
                  <motion.button
                    key={resolution.value}
                    onClick={() => handleResolutionChange(resolution.value)}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    className={clsx(
                      'w-full p-4 rounded-lg border-2 transition-all duration-200 text-left',
                      currentResolution === resolution.value
                        ? 'border-accent-primary bg-accent-primary/10'
                        : 'border-ui-border bg-primary-surface hover:border-accent-primary/50'
                    )}
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-2xl">{resolution.icon}</span>
                      <div className="flex-1">
                        <div className="font-semibold text-text-primary">
                          {resolution.label}
                        </div>
                      </div>
                      {currentResolution === resolution.value && (
                        <svg
                          className="w-6 h-6 text-accent-primary"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                        >
                          <path
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth={2}
                            d="M5 13l4 4L19 7"
                          />
                        </svg>
                      )}
                    </div>
                  </motion.button>
                ))}
              </div>
            </div>

            {/* Additional Settings (Future) */}
            <div className="pt-4 border-t border-ui-border">
              <h3 className="text-lg font-semibold text-text-primary mb-2">
                About
              </h3>
              <div className="space-y-2 text-sm text-text-secondary">
                <p>RM Insta Depo v7.0.0</p>
                <p>Modern Electron + React Edition</p>
                <p className="text-xs text-text-tertiary mt-4">
                  Built with ❤️ using Electron, React, TypeScript, and Tailwind CSS
                </p>
              </div>
            </div>
          </div>

          {/* Footer Buttons */}
          <div className="mt-6 flex gap-3">
            <button
              onClick={() => setSettingsOpen(false)}
              className="btn-secondary flex-1"
            >
              Cancel
            </button>
            <button
              onClick={handleApply}
              className="btn-primary flex-1"
            >
              Apply
            </button>
          </div>

          {/* Keyboard Shortcut Hint */}
          <div className="mt-4 text-center text-xs text-text-tertiary">
            Press ESC to close • F5 to open settings
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  )
}

export default Settings
