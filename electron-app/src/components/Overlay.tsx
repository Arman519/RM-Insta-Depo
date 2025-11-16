import { motion } from 'framer-motion'
import { useAppStore } from '../store/useAppStore'
import clsx from 'clsx'

const Overlay = () => {
  const {
    isAutoClickEnabled,
    currentTime,
    setAutoClickEnabled,
    setRecipeSearchOpen,
    setSettingsOpen,
  } = useAppStore()

  const hotkeyItems = [
    { key: 'F1', label: 'Depo', color: 'text-accent-primary', action: null },
    { key: 'F2', label: 'Loot Output', color: 'text-text-primary', action: null },
    { key: 'F3', label: 'Loot Input', color: 'text-text-primary', action: null },
    {
      key: 'F4',
      label: 'Recipe Search',
      color: 'text-text-secondary',
      action: () => setRecipeSearchOpen(true)
    },
    {
      key: 'F5',
      label: 'Select Res',
      color: 'text-text-secondary',
      action: () => setSettingsOpen(true)
    },
    {
      key: 'F6',
      label: `Auto Click (${isAutoClickEnabled ? 'ON' : 'OFF'})`,
      color: isAutoClickEnabled ? 'text-accent-success' : 'text-text-secondary',
      action: () => setAutoClickEnabled(!isAutoClickEnabled)
    },
    { key: 'F8', label: 'Show/Hide GUI', color: 'text-text-tertiary', action: null },
  ]

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.3 }}
      className="w-full h-full flex items-start justify-start p-0"
    >
      <div className="card w-[200px] draggable">
        {/* Title Bar */}
        <div className="mb-4">
          <h1 className="text-xl font-bold gradient-text">
            RM Insta Depo
          </h1>
          <div className="h-0.5 bg-gradient-to-r from-accent-primary to-accent-secondary rounded-full mt-2" />
        </div>

        {/* Hotkey List */}
        <div className="space-y-2 non-draggable">
          {hotkeyItems.map((item, index) => (
            <motion.div
              key={item.key}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.05 }}
              onClick={item.action || undefined}
              className={clsx(
                'flex items-center gap-2 text-sm transition-all duration-200',
                item.action && 'cursor-pointer hover:translate-x-1'
              )}
            >
              <span className="text-accent-primary">▸</span>
              <span className={clsx('font-medium', item.color)}>
                {item.key}:
              </span>
              <span className={item.color}>{item.label}</span>
            </motion.div>
          ))}
        </div>

        {/* Separator */}
        <div className="h-px bg-ui-border my-4" />

        {/* Clock */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="text-right font-mono text-sm text-accent-secondary"
        >
          {currentTime}
        </motion.div>

        {/* Status Indicator */}
        {isAutoClickEnabled && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 10 }}
            className="mt-3 flex items-center gap-2 text-xs"
          >
            <div className="w-2 h-2 bg-accent-success rounded-full animate-pulse" />
            <span className="text-accent-success font-medium">Auto-clicking active</span>
          </motion.div>
        )}
      </div>
    </motion.div>
  )
}

export default Overlay
