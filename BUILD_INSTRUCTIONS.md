# Building RM-Insta-Depo as a Standalone Application

## Quick Start Guide

### Method 1: AutoHotkey Compiler (Easiest) ⭐

#### Step 1: Install AutoHotkey
1. Download AutoHotkey v1.1+ from: https://www.autohotkey.com/
2. Run the installer and complete setup

#### Step 2: Compile to EXE
1. Right-click on `RM-Insta-Depo_S6_v2.ahk`
2. Select **"Compile Script"** from the context menu
3. Wait a few seconds - `RM-Insta-Depo_S6_v2.exe` will be created in the same folder

#### Step 3: Run
- Double-click `RM-Insta-Depo_S6_v2.exe` to run
- No AutoHotkey installation needed on other computers!

**File Size:** ~1-2 MB
**Requirements:** None (completely standalone)

---

### Method 2: Custom Compilation with Icon and Settings

#### Using Ahk2Exe (Built into AutoHotkey)

1. Find Ahk2Exe in your AutoHotkey installation folder:
   - Usually: `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe`

2. Open Ahk2Exe.exe

3. Configure compilation:
   - **Source (script file):** Browse to `RM-Insta-Depo_S6_v2.ahk`
   - **Destination (.exe file):** Choose output location and name
   - **Custom Icon:** (Optional) Add a custom .ico file
   - **Base File:** Use `AutoHotkeySC.bin` for 32-bit or `AutoHotkey64.exe` for 64-bit

4. Click **"Convert"**

5. Your standalone .exe is ready!

**Recommended Settings:**
- Use 64-bit version for better performance
- Add custom icon for professional look
- Enable compression to reduce file size

---

### Method 3: Create an Installer Package 📦

#### Using Inno Setup (Professional Installer)

1. **Download Inno Setup:** https://jrsoftware.org/isinfo.php

2. **Create setup script** (see `installer_script.iss` below)

3. **Compile installer:**
   - Open Inno Setup Compiler
   - Load the .iss script
   - Click "Compile"
   - Get a professional installer.exe

#### Sample Inno Setup Script

```ini
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
AppName=RM Insta Depo
AppVersion=6.2
AppPublisher=Your Name
DefaultDirName={autopf}\RM Insta Depo
DefaultGroupName=RM Insta Depo
OutputDir=.\Installer
OutputBaseFilename=RM-Insta-Depo-Setup
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "RM-Insta-Depo_S6_v2.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "UI_MODERNIZATION_SUMMARY.md"; DestDir: "{app}\docs"; Flags: ignoreversion

[Icons]
Name: "{group}\RM Insta Depo"; Filename: "{app}\RM-Insta-Depo_S6_v2.exe"
Name: "{group}\Uninstall RM Insta Depo"; Filename: "{uninstallexe}"
Name: "{autodesktop}\RM Insta Depo"; Filename: "{app}\RM-Insta-Depo_S6_v2.exe"

[Run]
Filename: "{app}\RM-Insta-Depo_S6_v2.exe"; Description: "Launch RM Insta Depo"; Flags: nowait postinstall skipifsilent
```

---

### Method 4: Portable Version with Launcher

Create a portable package that includes:

#### Folder Structure
```
RM-Insta-Depo-Portable/
├── RM-Insta-Depo.exe          (compiled main app)
├── README.txt                  (quick start guide)
├── LICENSE.txt
└── docs/
    ├── UI_MODERNIZATION_SUMMARY.md
    ├── MODERNIZATION_ROADMAP.md
    └── User_Guide.md
```

#### Create Portable ZIP
1. Compile the .ahk to .exe
2. Create folder structure above
3. Compress to ZIP file
4. Users extract and run - no installation needed!

**Benefits:**
- No installation required
- Run from USB drive
- Easy to distribute
- Clean and simple

---

## Comparison: Which Method to Choose?

| Method | Difficulty | Professional | Size | Best For |
|--------|-----------|-------------|------|----------|
| **Right-click Compile** | ⭐ Easy | ⭐⭐ Good | ~1-2MB | Quick distribution |
| **Ahk2Exe Custom** | ⭐⭐ Medium | ⭐⭐⭐ Great | ~1-2MB | Custom branding |
| **Inno Setup Installer** | ⭐⭐⭐ Advanced | ⭐⭐⭐⭐⭐ Professional | ~2-3MB | Enterprise/public release |
| **Portable ZIP** | ⭐ Easy | ⭐⭐⭐ Great | ~1-2MB | Personal use/sharing |

---

## Adding a Custom Icon 🎨

### Create or Download Icon
1. Create a 256x256 PNG logo
2. Convert to .ico format using: https://convertio.co/png-ico/
3. Save as `RM-Insta-Depo.ico`

### Apply to Compilation
- In Ahk2Exe: Select the .ico file in "Custom Icon" field
- Icon will appear in taskbar, desktop, and file explorer

---

## Advanced: Add Version Information

Create a file called `version_info.txt`:

```
FileVersion=6.2.0.0
ProductVersion=6.2.0.0
FileDescription=RM Insta Depo - Game Macro Tool
ProductName=RM Insta Depo
CompanyName=Your Name/Company
LegalCopyright=Copyright © 2025
```

Include in compilation for professional properties dialog.

---

## Testing Your Standalone App

### Before Distribution:
1. ✅ Test on clean Windows machine (no AutoHotkey installed)
2. ✅ Verify all hotkeys work (F1-F6, F8)
3. ✅ Test resolution selector dialog
4. ✅ Test recipe search functionality
5. ✅ Verify auto-click toggle works
6. ✅ Test on different screen resolutions (4K, QHD, FHD)
7. ✅ Check DPI scaling on high-resolution displays

---

## Distribution Options

### Option A: GitHub Release
1. Compile to .exe
2. Create GitHub release
3. Upload .exe as asset
4. Users download and run

### Option B: Direct Download
1. Host .exe on cloud storage (Dropbox, Google Drive)
2. Share link
3. Users download and run

### Option C: Installer Package
1. Create Inno Setup installer
2. Distribute single installer.exe
3. Professional installation experience

### Option D: Microsoft Store (Advanced)
1. Convert to MSIX package
2. Submit to Microsoft Store
3. Users install from Store

---

## Recommended Workflow for You

### **Best Approach for Quick Self-Running App:**

1. **Compile with Ahk2Exe:**
   - Use 64-bit base file
   - Add custom icon (create one at https://favicon.io/)
   - Enable compression

2. **Create Simple ZIP Package:**
   ```
   RM-Insta-Depo-v6.2/
   ├── RM-Insta-Depo.exe
   ├── README.txt (basic usage instructions)
   └── Quick-Start-Guide.pdf
   ```

3. **Test thoroughly** on clean machine

4. **Distribute via:**
   - GitHub Release (recommended)
   - Direct download link
   - Email/file sharing

**Time Required:** 5-10 minutes
**Result:** Professional, standalone application

---

## Troubleshooting

### "Windows protected your PC" message
- This is Windows SmartScreen for unsigned executables
- **Solution 1:** Click "More info" → "Run anyway"
- **Solution 2:** Sign the executable with a code signing certificate (~$100-300/year)
- **Solution 3:** Distribute source code and let users compile themselves

### Antivirus false positives
- Some antivirus software flags AutoHotkey executables
- **Solution:** Submit to antivirus vendors for whitelisting
- **Alternative:** Provide both .exe and .ahk versions

### Large file size
- Standard AutoHotkey .exe is ~1-2MB (includes runtime)
- **Solution:** Use UPX compression (built into Ahk2Exe)
- Enable "MPRESS or UPX" in compilation options

---

## Next Steps

1. Choose your method (I recommend **Method 2: Ahk2Exe Custom**)
2. Create a custom icon
3. Compile to .exe
4. Test thoroughly
5. Create distribution package
6. Share with users!

**Need help with any step? Let me know!**
