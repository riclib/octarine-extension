#!/bin/bash

echo "=== Restarting Arc Browser ==="
echo

# Kill all Arc processes
echo "1. Stopping Arc browser..."
osascript -e 'quit app "Arc"' 2>/dev/null
sleep 2

# Make sure all processes are gone
pkill -f "Arc.app" 2>/dev/null
sleep 1

echo "2. Clearing extension cache..."
# Clear any extension state that might be cached
rm -rf "$HOME/Library/Application Support/Arc/Default/Extension State" 2>/dev/null
rm -rf "$HOME/Library/Application Support/Arc/User Data/Default/Extension State" 2>/dev/null

echo "3. Verifying native messaging manifest..."
MANIFEST_PATH="$HOME/Library/Application Support/Arc/User Data/NativeMessagingHosts/com.octarine.clipper.json"
if [[ -f "$MANIFEST_PATH" ]]; then
    echo "   ✓ Manifest found at: $MANIFEST_PATH"
    echo "   Content:"
    cat "$MANIFEST_PATH" | python3 -m json.tool | sed 's/^/     /'
else
    echo "   ✗ Manifest not found!"
fi

echo
echo "4. Starting Arc..."
open -a "Arc"

echo
echo "=== Next Steps ==="
echo "1. Wait for Arc to fully load"
echo "2. Go to chrome://extensions/"
echo "3. Toggle the Octarine extension OFF and then ON"
echo "4. Open the extension console (click 'service worker')"
echo "5. Try clipping a page"
echo
echo "If it still fails, try:"
echo "- Remove and re-add the extension"
echo "- Check Arc menu > Preferences > Extensions for any settings"