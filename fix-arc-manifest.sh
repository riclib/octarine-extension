#!/bin/bash

echo "=== Installing Native Messaging Manifest in All Arc Locations ==="
echo

# The manifest content
MANIFEST_CONTENT='{
  "name": "com.octarine.clipper",
  "description": "Octarine Web Clipper Native Host",
  "path": "/Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://ccpoplhmbhhjaileoijblcocnhonmmch/"
  ]
}'

# All possible locations where Arc might look
LOCATIONS=(
    "$HOME/Library/Application Support/Arc/NativeMessagingHosts"
    "$HOME/Library/Application Support/Arc/User Data/NativeMessagingHosts"
    "$HOME/Library/Application Support/Arc/User Data/Default/NativeMessagingHosts"
    "$HOME/Library/Application Support/Arc/User Data/Profile 1/NativeMessagingHosts"
    "$HOME/Library/Application Support/Arc/User Data/Profile 2/NativeMessagingHosts"
)

echo "Installing manifest in all possible locations:"
for LOCATION in "${LOCATIONS[@]}"; do
    echo -n "  $LOCATION ... "
    mkdir -p "$LOCATION" 2>/dev/null
    echo "$MANIFEST_CONTENT" > "$LOCATION/com.octarine.clipper.json"
    if [[ $? -eq 0 ]]; then
        echo "✓"
    else
        echo "✗"
    fi
done

echo
echo "Verifying installations:"
for LOCATION in "${LOCATIONS[@]}"; do
    if [[ -f "$LOCATION/com.octarine.clipper.json" ]]; then
        echo "  ✓ $LOCATION/com.octarine.clipper.json"
    fi
done

echo
echo "=== Next Steps ==="
echo "1. Restart Arc completely (Cmd+Q)"
echo "2. Reopen Arc"
echo "3. Go to chrome://extensions/"
echo "4. Toggle the Octarine extension OFF and ON"
echo "5. Try clipping again"
echo
echo "If it still doesn't work, try removing and reinstalling the extension."