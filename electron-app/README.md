# RM Insta Depo - Electron + React Edition

Modern, professional desktop application built with Electron, React, TypeScript, and Tailwind CSS.

![Version](https://img.shields.io/badge/version-7.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- **Modern UI**: Beautiful Material Design-inspired interface with smooth animations
- **Cross-Platform**: Works on Windows, macOS, and Linux
- **DPI Aware**: Perfect rendering on 4K, QHD, and Full HD displays
- **Global Hotkeys**: F1-F8 hotkeys work even when app is in background
- **Recipe Search**: Fast, real-time search through 500+ crafting recipes
- **Auto-Click**: Toggle-able auto-click functionality
- **Customizable**: Change resolution settings, themes, and more
- **Transparent Overlay**: Always-on-top draggable overlay window

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ (Download from [nodejs.org](https://nodejs.org/))
- npm or yarn package manager

### Installation

1. **Clone and navigate to the electron-app directory:**
   ```bash
   cd electron-app
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Run in development mode:**
   ```bash
   npm run electron:dev
   ```

4. **Build for production:**
   ```bash
   npm run build:win   # Windows
   npm run build:mac   # macOS
   npm run build:linux # Linux
   ```

## 📦 Project Structure

```
electron-app/
├── electron/               # Electron main process
│   ├── main.ts            # Main process entry
│   ├── preload.ts         # Preload script (IPC bridge)
│   └── recipes.ts         # Recipe database
├── src/                   # React application
│   ├── components/        # UI components
│   │   ├── Overlay.tsx    # Main overlay window
│   │   ├── RecipeSearch.tsx
│   │   └── Settings.tsx
│   ├── store/             # State management (Zustand)
│   │   └── useAppStore.ts
│   ├── styles/            # CSS styles
│   │   └── index.css      # Tailwind + custom styles
│   ├── App.tsx            # Root component
│   └── main.tsx           # React entry point
├── package.json           # Dependencies and scripts
├── vite.config.ts         # Vite configuration
├── tailwind.config.js     # Tailwind CSS config
└── tsconfig.json          # TypeScript config
```

## 🎮 Hotkeys

| Key | Function |
|-----|----------|
| **F1** | Depo (Main function) |
| **F2** | Loot Output |
| **F3** | Loot Input |
| **F4** | Toggle Recipe Search |
| **F5** | Toggle Settings |
| **F6** | Toggle Auto-Click |
| **F8** | Show/Hide Overlay |

## 🎨 Technology Stack

### Frontend
- **React 18** - UI framework
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first CSS framework
- **Framer Motion** - Smooth animations
- **Zustand** - Lightweight state management

### Desktop
- **Electron 28** - Cross-platform desktop framework
- **Vite** - Lightning-fast build tool
- **RobotJS** - Native automation library

## 🛠️ Development

### Available Scripts

```bash
# Development
npm run electron:dev       # Run app in development mode with hot reload
npm run dev               # Run Vite dev server only

# Building
npm run build             # Build for all platforms
npm run build:win         # Build for Windows (NSIS installer + portable)
npm run build:mac         # Build for macOS (DMG + ZIP)
npm run build:linux       # Build for Linux (AppImage + DEB)

# Code Quality
npm run lint              # Run ESLint
npm run format            # Format code with Prettier
```

### Development Workflow

1. **Start development server:**
   ```bash
   npm run electron:dev
   ```
   - Vite dev server starts at `http://localhost:5173`
   - Electron window opens automatically
   - Hot reload enabled for instant updates

2. **Make changes:**
   - Edit React components in `src/`
   - Edit Electron code in `electron/`
   - Changes auto-reload in development

3. **Test:**
   - Test all hotkeys (F1-F8)
   - Test recipe search
   - Test auto-click functionality
   - Test on different screen resolutions

4. **Build:**
   ```bash
   npm run build:win
   ```
   - Output in `release/` directory
   - Installer and portable versions created

## 📱 UI Components

### Overlay Window
- **Location**: `src/components/Overlay.tsx`
- **Features**: Draggable, transparent, always-on-top
- **Size**: 200x240px (responsive to DPI)

### Recipe Search
- **Location**: `src/components/RecipeSearch.tsx`
- **Features**: Real-time search, modal dialog
- **Database**: 500+ recipes with categories

### Settings
- **Location**: `src/components/Settings.tsx`
- **Features**: Resolution selector, app info

## 🎨 Theming & Customization

### Color Palette

The app uses a custom color palette defined in `tailwind.config.js`:

```javascript
colors: {
  primary: {
    bg: '#1E1E2E',       // Deep dark background
    surface: '#242438',   // Card surfaces
    elevated: '#2D2D44'   // Elevated elements
  },
  accent: {
    primary: '#7AA2F7',   // Vibrant blue
    secondary: '#BB9AF7', // Purple
    success: '#9ECE6A',   // Green
    warning: '#E0AF68',   // Orange
    error: '#F7768E'      // Red
  },
  text: {
    primary: '#C0CAF5',   // Main text
    secondary: '#9AA5CE', // Secondary text
    tertiary: '#565F89'   // Muted text
  }
}
```

### Customizing Colors

Edit `tailwind.config.js` to change the color scheme:

```javascript
extend: {
  colors: {
    accent: {
      primary: '#YOUR_COLOR',  // Change primary accent
    }
  }
}
```

## 🚢 Building for Distribution

### Windows

```bash
npm run build:win
```

**Output:**
- `release/7.0.0/RM Insta Depo Setup 7.0.0.exe` - NSIS Installer
- `release/7.0.0/RM Insta Depo 7.0.0.exe` - Portable version

**Installer Features:**
- Custom install directory
- Start menu shortcuts
- Desktop shortcut (optional)
- Uninstaller

### macOS

```bash
npm run build:mac
```

**Output:**
- `release/7.0.0/RM Insta Depo-7.0.0.dmg` - DMG installer
- `release/7.0.0/RM Insta Depo-7.0.0-mac.zip` - ZIP archive

**Requirements:**
- Code signing certificate (for notarization)
- macOS 10.15+ for building

### Linux

```bash
npm run build:linux
```

**Output:**
- `release/7.0.0/RM Insta Depo-7.0.0.AppImage` - AppImage (universal)
- `release/7.0.0/rm-insta-depo_7.0.0_amd64.deb` - Debian package

## 🔧 Configuration

### Electron Builder

Edit `package.json` under the `build` section:

```json
"build": {
  "appId": "com.rminsta.depo",
  "productName": "RM Insta Depo",
  "win": {
    "target": ["nsis", "portable"],
    "icon": "assets/icon.ico"
  }
}
```

### Vite

Edit `vite.config.ts` for build configuration:

```typescript
export default defineConfig({
  server: {
    port: 5173  // Dev server port
  }
})
```

## 🐛 Troubleshooting

### Common Issues

**1. "Module not found" errors**
```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

**2. Electron window doesn't open**
```bash
# Check if port 5173 is already in use
lsof -i :5173
# Kill the process and restart
```

**3. Build fails on Windows**
```bash
# Install windows-build-tools
npm install --global windows-build-tools
```

**4. RobotJS installation fails**
```bash
# Install dependencies for RobotJS
# Windows: Visual Studio Build Tools
# macOS: Xcode Command Line Tools
# Linux: libxtst-dev, libpng-dev
```

## 📝 License

MIT License - see LICENSE file for details

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Guidelines

1. Follow TypeScript best practices
2. Use functional components with hooks
3. Follow the existing code style
4. Test on all supported platforms
5. Update documentation for new features

## 🆕 What's New in v7.0

- ✅ Complete rewrite in Electron + React
- ✅ Modern Material Design UI
- ✅ Smooth animations with Framer Motion
- ✅ TypeScript for type safety
- ✅ Tailwind CSS for styling
- ✅ Global hotkeys support
- ✅ Cross-platform compatibility
- ✅ Real-time recipe search
- ✅ Customizable settings
- ✅ Professional build system

## 🎯 Roadmap

### Planned Features

- [ ] Macro recording and playback
- [ ] Multiple profiles support
- [ ] Cloud backup of settings
- [ ] Plugin system
- [ ] Multi-language support
- [ ] Theme customization UI
- [ ] Auto-updater
- [ ] Usage statistics
- [ ] Hotkey customization UI

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/Arman519/RM-Insta-Depo/issues)
- **Documentation**: This README
- **Community**: [Discussions](https://github.com/Arman519/RM-Insta-Depo/discussions)

## 🙏 Acknowledgments

- Built with [Electron](https://www.electronjs.org/)
- UI powered by [React](https://react.dev/)
- Styled with [Tailwind CSS](https://tailwindcss.com/)
- Animations by [Framer Motion](https://www.framer.com/motion/)
- State management with [Zustand](https://github.com/pmndrs/zustand)

---

**Made with ❤️ by the RM Insta Depo Team**
