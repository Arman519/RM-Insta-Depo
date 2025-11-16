# RM Insta Depo - Quick Start Guide

## 🚀 Get Started in 3 Minutes

### Step 1: Install Node.js (if not already installed)

1. Go to [nodejs.org](https://nodejs.org/)
2. Download the LTS version (recommended)
3. Run the installer
4. Verify installation:
   ```bash
   node --version
   npm --version
   ```

### Step 2: Install Dependencies

Open terminal/command prompt in the `electron-app` folder:

```bash
cd electron-app
npm install
```

**This will take 2-3 minutes**. It downloads all required packages.

### Step 3: Run the App

```bash
npm run electron:dev
```

The app will open automatically! 🎉

---

## 🎮 Using the App

### Main Overlay

The app appears as a small overlay window in the top-left corner.

**You can:**
- Drag it anywhere on screen
- Click on any menu item
- Use hotkeys (F1-F8)

### Hotkeys

- **F1** - Depo function
- **F2** - Loot Output
- **F3** - Loot Input
- **F4** - Open Recipe Search
- **F5** - Open Settings
- **F6** - Toggle Auto-Click
- **F8** - Show/Hide Overlay

### Recipe Search

1. Press **F4** or click "F4: Recipe Search"
2. Type item name (e.g., "iron", "fiber", "ballista")
3. Results appear instantly
4. Press ESC to close

### Settings

1. Press **F5** or click "F5: Select Res"
2. Choose your screen resolution:
   - 3840 x 2160 (4K UHD)
   - 2560 x 1440 (QHD)
   - 1920 x 1080 (Full HD)
3. Click Apply

---

## 📦 Building Standalone App

### For Windows:

```bash
npm run build:win
```

**Output:** `release/7.0.0/RM Insta Depo Setup 7.0.0.exe`

**Size:** ~150 MB

**What you get:**
- Professional Windows installer
- Desktop shortcut
- Start menu entry
- Uninstaller

### For macOS:

```bash
npm run build:mac
```

**Output:** `release/7.0.0/RM Insta Depo-7.0.0.dmg`

### For Linux:

```bash
npm run build:linux
```

**Output:** `release/7.0.0/RM Insta Depo-7.0.0.AppImage`

---

## 🛠️ Troubleshooting

### "npm: command not found"

**Solution:** Install Node.js from [nodejs.org](https://nodejs.org/)

### "EACCES: permission denied"

**On Linux/Mac:**
```bash
sudo chown -R $(whoami) ~/.npm
```

### Build fails on Windows

**Solution:** Install Windows Build Tools
```bash
npm install --global windows-build-tools
```

### Port 5173 already in use

**Solution:** Kill the process or change port in `vite.config.ts`

### RobotJS installation fails

**Windows:**
- Install Visual Studio Build Tools
- https://visualstudio.microsoft.com/downloads/

**macOS:**
```bash
xcode-select --install
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install libxtst-dev libpng++-dev
```

---

## 💡 Development Tips

### Hot Reload

When running in dev mode (`npm run electron:dev`):
- Save any file in `src/` → UI updates instantly
- Save any file in `electron/` → App restarts automatically

### Debugging

**Open DevTools:**
- Press `Ctrl+Shift+I` (Windows/Linux)
- Press `Cmd+Option+I` (macOS)

**Console Logs:**
- Use `console.log()` in React components
- Use `console.log()` in Electron main process
- Logs appear in DevTools Console

### Making Changes

**Change UI Colors:**
- Edit `tailwind.config.js`
- Modify the `colors` section

**Add New Recipes:**
- Edit `electron/recipes.ts`
- Add to the `recipes` array

**Change Hotkeys:**
- Edit `electron/main.ts`
- Modify `registerHotkeys()` function

**Add New Features:**
1. Create component in `src/components/`
2. Import in `src/App.tsx`
3. Add to Zustand store if needed

---

## 📚 Next Steps

### Learn More

- **React Tutorial:** [react.dev](https://react.dev/)
- **Electron Guide:** [electronjs.org/docs](https://www.electronjs.org/docs/latest/)
- **Tailwind CSS:** [tailwindcss.com/docs](https://tailwindcss.com/docs)
- **TypeScript:** [typescriptlang.org](https://www.typescriptlang.org/)

### Customize

1. **Change app name:**
   - Edit `package.json` → `name` and `productName`
   - Edit `package.json` → `build.productName`

2. **Add custom icon:**
   - Create `assets/icon.ico` (Windows)
   - Create `assets/icon.icns` (macOS)
   - Create `assets/icon.png` (Linux)

3. **Change window size:**
   - Edit `electron/main.ts`
   - Modify `createOverlayWindow()` function

### Deploy

1. Build for your platform
2. Test the installer
3. Share with users
4. Get feedback
5. Iterate!

---

## 🎯 Common Tasks

### Update Dependencies

```bash
npm update
```

### Clean Install

```bash
rm -rf node_modules package-lock.json
npm install
```

### Check for Outdated Packages

```bash
npm outdated
```

### Run Linter

```bash
npm run lint
```

### Format Code

```bash
npm run format
```

---

## ✅ Checklist

Before building for production:

- [ ] Test all hotkeys (F1-F8)
- [ ] Test recipe search
- [ ] Test auto-click toggle
- [ ] Test on all supported resolutions
- [ ] Run linter: `npm run lint`
- [ ] Fix any TypeScript errors
- [ ] Update version in `package.json`
- [ ] Create app icon
- [ ] Test build process
- [ ] Test installer on clean machine

---

## 🆘 Getting Help

**Found a bug?**
- Check [GitHub Issues](https://github.com/Arman519/RM-Insta-Depo/issues)
- Create new issue with details

**Have a question?**
- Check this guide first
- Read the full [README.md](README.md)
- Ask in [GitHub Discussions](https://github.com/Arman519/RM-Insta-Depo/discussions)

**Want to contribute?**
- Fork the repository
- Make your changes
- Submit a Pull Request

---

## 🎉 Success!

You now have a modern, professional Electron app running!

**Enjoy your new app!** 🚀

---

**Last Updated:** 2025-10-30
**Version:** 7.0.0
