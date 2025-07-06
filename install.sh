#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🐙 Octarine Extension Installer"
echo "=============================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

# Check for Swift
if ! command -v swift &> /dev/null; then
    echo -e "${RED}✗ Swift not found${NC}"
    echo "Please install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
else
    echo -e "${GREEN}✓ Swift found${NC}"
fi

# Check if we're in the right directory
if [ ! -f "install.sh" ] || [ ! -d "chrome-extension" ]; then
    echo -e "${RED}✗ Error: Please run this script from the octarine-extension directory${NC}"
    exit 1
fi

# Check for compatible browsers
BROWSER_FOUND=false
NATIVE_HOST_DIR=""

if [ -d "/Applications/Google Chrome.app" ]; then
    BROWSER_FOUND=true
    NATIVE_HOST_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
    echo -e "${GREEN}✓ Google Chrome found${NC}"
elif [ -d "/Applications/Arc.app" ]; then
    BROWSER_FOUND=true
    NATIVE_HOST_DIR="$HOME/Library/Application Support/Arc/User Data/NativeMessagingHosts"
    echo -e "${GREEN}✓ Arc browser found${NC}"
fi

if [ "$BROWSER_FOUND" = false ]; then
    echo -e "${YELLOW}Warning: No compatible browser found${NC}"
    echo "You'll need Chrome or Arc to use the extension, but we can continue with the Swift app installation."
    echo ""
    # Use Chrome's directory as default
    NATIVE_HOST_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
fi

# Save original manifest if it exists
MANIFEST_PATH="swift-app/com.octarine.clipper.json"
if [ -f "$MANIFEST_PATH.original" ]; then
    echo -e "${BLUE}Found existing backup of manifest${NC}"
else
    cp "$MANIFEST_PATH" "$MANIFEST_PATH.original" 2>/dev/null || true
fi

# Get the extension ID (this will be shown after loading the unpacked extension)
echo ""
echo -e "${YELLOW}IMPORTANT: Make sure you've already loaded the extension in Chrome!${NC}"
echo "1. Open chrome://extensions"
echo "2. Enable Developer mode"
echo "3. Click 'Load unpacked' and select the 'chrome-extension' folder"
echo "4. Copy the Extension ID shown on the extension card"
echo ""
read -p "Enter your Chrome extension ID: " EXTENSION_ID

if [ -z "$EXTENSION_ID" ]; then
    echo -e "${RED}Error: Extension ID is required${NC}"
    echo "Please load the extension in Chrome first, then run this installer again."
    exit 1
fi

# Validate extension ID format (should be 32 lowercase letters)
if ! [[ "$EXTENSION_ID" =~ ^[a-z]{32}$ ]]; then
    echo -e "${YELLOW}Warning: Extension ID format looks unusual${NC}"
    echo "Expected format: 32 lowercase letters (e.g., ccpoplhmbhhjaileoijblcocnhonmmch)"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update the native messaging host manifest
# First restore from original to handle multiple runs
if [ -f "$MANIFEST_PATH.original" ]; then
    cp "$MANIFEST_PATH.original" "$MANIFEST_PATH"
fi

sed -i '' "s/YOUR_EXTENSION_ID_HERE/$EXTENSION_ID/g" "$MANIFEST_PATH"

# Create native messaging host directory
mkdir -p "$NATIVE_HOST_DIR"

# Copy the manifest
cp "$MANIFEST_PATH" "$NATIVE_HOST_DIR/"

echo -e "${GREEN}✓ Native messaging host manifest installed${NC}"

# Build the Swift app
echo ""
echo "Building Swift menubar app..."
cd swift-app/OctarineMenubar
swift build -c release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Swift app built successfully${NC}"
    
    # Create a simple app bundle
    APP_DIR="/Applications/OctarineMenubar.app"
    mkdir -p "$APP_DIR/Contents/MacOS"
    cp .build/release/OctarineMenubar "$APP_DIR/Contents/MacOS/"
    
    # Create Info.plist
    cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>OctarineMenubar</string>
    <key>CFBundleIdentifier</key>
    <string>com.octarine.menubar</string>
    <key>CFBundleName</key>
    <string>Octarine</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF
    
    echo -e "${GREEN}✓ App installed to /Applications/OctarineMenubar.app${NC}"
else
    echo -e "${RED}✗ Failed to build Swift app${NC}"
    exit 1
fi

    # Try to launch the app
    echo ""
    echo "Launching Octarine menubar app..."
    if open /Applications/OctarineMenubar.app 2>/dev/null; then
        echo -e "${GREEN}✓ App launched successfully${NC}"
    else
        echo -e "${YELLOW}Please launch the app manually:${NC}"
        echo "  open /Applications/OctarineMenubar.app"
    fi

echo ""
echo -e "${GREEN}🎉 Installation complete!${NC}"
echo ""
echo -e "${BLUE}Quick Test:${NC}"
echo "1. Look for the 📄 icon in your menubar"
echo "2. Go to any webpage"
echo "3. Press Cmd+Shift+S to clip it"
echo "4. Watch for the ✓ badge on the extension icon"
echo ""
echo -e "${BLUE}Your clippings will be saved to:${NC}"
echo "  ~/Documents/Octarine/clippings/"
echo ""
echo -e "${YELLOW}Remember:${NC} If you remove and reload the extension,"
echo "it will get a new ID. Just run this installer again!"

# Make the script executable
chmod +x "$0"