#!/bin/bash

echo "=== Update Chrome Native Messaging Manifest ==="
echo

# Get the extension ID from user
echo "After loading the extension in Chrome, copy the Extension ID"
echo "It looks like: abcdefghijklmnopqrstuvwxyzabcdef"
echo
read -p "Enter the Chrome Extension ID: " EXTENSION_ID

if [[ -z "$EXTENSION_ID" ]]; then
    echo "Error: No extension ID provided"
    exit 1
fi

# Update the manifest
MANIFEST_PATH="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.octarine.clipper.json"

cat > "$MANIFEST_PATH" << EOF
{
  "name": "com.octarine.clipper",
  "description": "Octarine Web Clipper Native Host",
  "path": "/Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://${EXTENSION_ID}/"
  ]
}
EOF

echo
echo "✓ Updated Chrome manifest with extension ID: $EXTENSION_ID"
echo
echo "Contents of $MANIFEST_PATH:"
cat "$MANIFEST_PATH" | python3 -m json.tool

echo
echo "=== Next Steps ==="
echo "1. In Chrome, go to the Octarine extension"
echo "2. Click on 'service worker' or 'background page'"
echo "3. This opens the Developer Console"
echo "4. Try clipping a page (Cmd+Shift+S or click extension icon)"
echo "5. Check the console for any errors"