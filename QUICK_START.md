# Octarine Quick Start Guide

Get up and running in 5 minutes! This guide assumes you have macOS, Chrome, and basic development tools.

## 🚀 Fast Track Installation

### 1. Clone & Prepare (30 seconds)
```bash
git clone https://github.com/riclib/octarine-extension.git
cd octarine-extension
chmod +x install.sh
```

### 2. Load Extension in Chrome (1 minute)
1. Open Chrome → `chrome://extensions`
2. Enable "Developer mode" (top right)
3. Click "Load unpacked"
4. Select the `chrome-extension` folder
5. **COPY THE EXTENSION ID!** (looks like: `ccpoplhmbhhjaileoijblcocnhonmmch`)

### 3. Run Installer (2-3 minutes)
```bash
./install.sh
# Paste your Extension ID when prompted
```

### 4. Start Clipping! (10 seconds)
- Press `Cmd+Shift+S` on any webpage
- Or click the Octarine extension icon
- Look for ✓ badge = success!

## ✅ Quick Verification

```bash
# Check if app is running
ps aux | grep OctarineMenubar

# Check if clippings are saved
ls ~/Documents/Octarine/clippings/

# Manually start app if needed
open /Applications/OctarineMenubar.app
```

## 🔧 Quick Fixes

**Nothing happens when clipping?**
```bash
pkill OctarineMenubar && open /Applications/OctarineMenubar.app
```

**"Access forbidden" error?**
- Your Extension ID changed! Re-run `./install.sh` with the new ID

**No Swift installed?**
```bash
xcode-select --install
```

## 📍 Where Things Are

- **Clippings**: `~/Documents/Octarine/clippings/`
- **Daily Notes**: `~/Documents/Octarine/daily/`
- **App**: `/Applications/OctarineMenubar.app`
- **Extension**: Chrome toolbar

## 🎯 First Clip Test

1. Go to any article (try [example.com](https://example.com))
2. Press `Cmd+Shift+S`
3. Look for the ✓ badge on extension icon
4. Check `~/Documents/Octarine/clippings/` for your file!

---

Need more help? See the full [User Guide](docs/USER_GUIDE.md) or [Troubleshooting](docs/TROUBLESHOOTING.md).