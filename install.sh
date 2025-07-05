#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🐙 Octarine Extension Installer"
echo "=============================="
echo ""

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

# Get the extension ID (this will be shown after loading the unpacked extension)
read -p "Enter your Chrome extension ID (found in chrome://extensions): " EXTENSION_ID

if [ -z "$EXTENSION_ID" ]; then
    echo -e "${RED}Error: Extension ID is required${NC}"
    exit 1
fi

# Update the native messaging host manifest
MANIFEST_PATH="swift-app/com.octarine.clipper.json"
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

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Load the Chrome extension:"
echo "   - Open chrome://extensions"
echo "   - Enable Developer mode"
echo "   - Click 'Load unpacked'"
echo "   - Select the 'chrome-extension' folder"
echo ""
echo "2. Launch the Octarine menubar app:"
echo "   - Run: open /Applications/OctarineMenubar.app"
echo "   - Or add it to your login items for automatic startup"
echo ""
echo "3. Start clipping!"
echo "   - Use Cmd+Shift+S on any webpage"
echo "   - Or click the extension icon"

# Make the script executable
chmod +x "$0"