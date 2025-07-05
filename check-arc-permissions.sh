#!/bin/bash

echo "=== Checking Arc Browser Permissions ==="
echo

# Check if Arc has full disk access
echo "1. Checking Arc's system permissions:"
echo "   Note: Arc needs permission to execute apps for native messaging"
echo

# Check quarantine attributes on the native app
echo "2. Checking quarantine status of native app:"
xattr -l /Applications/OctarineMenubar.app 2>/dev/null
if [[ $? -eq 0 ]]; then
    echo "   If you see 'com.apple.quarantine', the app might be blocked"
    echo "   To remove quarantine: xattr -r -d com.apple.quarantine /Applications/OctarineMenubar.app"
else
    echo "   No extended attributes found (good)"
fi
echo

# Check if the app is signed
echo "3. Checking code signature:"
codesign -v /Applications/OctarineMenubar.app 2>&1
echo

# Check Gatekeeper status
echo "4. Checking Gatekeeper assessment:"
spctl -a -v /Applications/OctarineMenubar.app 2>&1
echo

# Try to see if there are any sandbox restrictions
echo "5. Checking for sandbox restrictions:"
ps aux | grep -i arc | head -5
echo

echo "=== Recommendations ==="
echo "If you see errors above, try:"
echo "1. Remove quarantine: sudo xattr -r -d com.apple.quarantine /Applications/OctarineMenubar.app"
echo "2. Allow in System Settings > Privacy & Security"
echo "3. If unsigned, you may need to right-click and select 'Open' first"