import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { useAppStore } from '../store/useAppStore'

interface Recipe {
  name: string
  materials: string
  category?: string
}

const RecipeSearch = () => {
  const { setRecipeSearchOpen } = useAppStore()
  const [searchQuery, setSearchQuery] = useState('')
  const [results, setResults] = useState<Recipe[]>([])
  const [isSearching, setIsSearching] = useState(false)

  const handleSearch = async () => {
    if (!searchQuery.trim()) {
      setResults([])
      return
    }

    setIsSearching(true)

    if (window.electronAPI) {
      try {
        const searchResults = await window.electronAPI.searchRecipe(searchQuery)
        setResults(searchResults)
      } catch (error) {
        console.error('Search error:', error)
        setResults([])
      } finally {
        setIsSearching(false)
      }
    } else {
      // Fallback for development
      setIsSearching(false)
    }
  }

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSearch()
    } else if (e.key === 'Escape') {
      setRecipeSearchOpen(false)
    }
  }

  useEffect(() => {
    // Auto-search as user types (with debounce)
    const timer = setTimeout(() => {
      if (searchQuery) {
        handleSearch()
      }
    }, 300)

    return () => clearTimeout(timer)
  }, [searchQuery])

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50"
        onClick={() => setRecipeSearchOpen(false)}
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
                🔍 Recipe Search
              </h2>
              <p className="text-sm text-text-secondary mt-1">
                Find crafting materials and recipes
              </p>
            </div>
            <button
              onClick={() => setRecipeSearchOpen(false)}
              className="text-text-tertiary hover:text-text-primary transition-colors"
            >
              <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Search Bar */}
          <div className="flex gap-2 mb-4">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyDown={handleKeyPress}
              placeholder="Type recipe name..."
              className="input flex-1"
              autoFocus
            />
            <button
              onClick={handleSearch}
              disabled={isSearching || !searchQuery.trim()}
              className="btn-primary px-6 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isSearching ? '...' : 'Search'}
            </button>
          </div>

          {/* Results */}
          <div className="bg-primary-bg rounded-lg p-4 max-h-[400px] overflow-y-auto custom-scrollbar">
            {results.length === 0 && !isSearching && (
              <div className="text-center py-8 text-text-tertiary">
                {searchQuery ? (
                  <p>No recipes found for "{searchQuery}"</p>
                ) : (
                  <div className="space-y-2">
                    <p className="text-4xl">💡</p>
                    <p>Type a recipe name above and press Enter</p>
                    <p className="text-xs mt-4">Tip: Search is case-insensitive</p>
                  </div>
                )}
              </div>
            )}

            {isSearching && (
              <div className="text-center py-8 text-text-secondary">
                <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-accent-primary"></div>
                <p className="mt-2">Searching...</p>
              </div>
            )}

            <div className="space-y-3">
              {results.map((recipe, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05 }}
                  className="bg-primary-surface rounded-lg p-3 border border-ui-border/30 hover:border-accent-primary/50 transition-colors"
                >
                  <div className="flex items-start justify-between">
                    <h3 className="font-semibold text-text-primary">{recipe.name}</h3>
                    {recipe.category && (
                      <span className="text-xs px-2 py-1 rounded-full bg-accent-primary/20 text-accent-primary">
                        {recipe.category}
                      </span>
                    )}
                  </div>
                  <p className="text-sm text-text-secondary mt-2 font-mono">
                    {recipe.materials}
                  </p>
                </motion.div>
              ))}
            </div>
          </div>

          {/* Footer */}
          <div className="mt-4 flex justify-between items-center text-xs text-text-tertiary">
            <span>Press ESC to close</span>
            <span>{results.length} result{results.length !== 1 ? 's' : ''}</span>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  )
}

export default RecipeSearch
