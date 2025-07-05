#!/bin/bash

echo "=== Octarine Native Messaging Diagnostic ==="
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the extension ID from user or use the known one
EXTENSION_ID="${1:-ccpoplhmbhhjaileoijblcocnhonmmch}"
echo "Using Extension ID: $EXTENSION_ID"
echo

# Function to check if a file exists and is readable
check_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} Found: $file"
        if [[ -r "$file" ]]; then
            echo -e "  ${GREEN}✓${NC} Readable"
        else
            echo -e "  ${RED}✗${NC} Not readable"
        fi
        # Check if it's a symlink
        if [[ -L "$file" ]]; then
            local target=$(readlink "$file")
            echo -e "  → Symlink to: $target"
            if [[ -f "$target" ]]; then
                echo -e "    ${GREEN}✓${NC} Target exists"
            else
                echo -e "    ${RED}✗${NC} Target missing!"
            fi
        fi
    else
        echo -e "${RED}✗${NC} Missing: $file"
        return 1
    fi
    return 0
}

# Function to check JSON validity
check_json() {
    local file="$1"
    if python3 -m json.tool "$file" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Valid JSON"
        return 0
    else
        echo -e "  ${RED}✗${NC} Invalid JSON!"
        python3 -m json.tool "$file" 2>&1 | head -5
        return 1
    fi
}

# 1. Check native messaging host directories
echo "1. Checking native messaging host directories:"
echo "   For Arc Browser:"
ARC_DIR="$HOME/Library/Application Support/Arc/User Data/NativeMessagingHosts"
ARC_ALT_DIR="$HOME/Library/Application Support/Arc/NativeMessagingHosts"
if [[ -d "$ARC_DIR" ]]; then
    echo -e "   ${GREEN}✓${NC} Arc directory exists: $ARC_DIR"
elif [[ -d "$ARC_ALT_DIR" ]]; then
    echo -e "   ${GREEN}✓${NC} Arc directory exists: $ARC_ALT_DIR"
    ARC_DIR="$ARC_ALT_DIR"
else
    echo -e "   ${RED}✗${NC} Arc directory missing"
fi

echo "   For Chrome:"
CHROME_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
if [[ -d "$CHROME_DIR" ]]; then
    echo -e "   ${GREEN}✓${NC} Chrome directory exists: $CHROME_DIR"
else
    echo -e "   ${YELLOW}!${NC} Chrome directory missing: $CHROME_DIR (OK if using Arc)"
fi
echo

# 2. Check manifest files
echo "2. Checking native messaging manifest files:"
ARC_MANIFEST="$ARC_DIR/com.octarine.clipper.json"
CHROME_MANIFEST="$CHROME_DIR/com.octarine.clipper.json"

if check_file "$ARC_MANIFEST"; then
    check_json "$ARC_MANIFEST"
    echo "   Content:"
    cat "$ARC_MANIFEST" | python3 -m json.tool | sed 's/^/     /'
fi
echo

# 3. Check the native app
echo "3. Checking native application:"
APP_PATH="/Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar"
if check_file "$APP_PATH"; then
    # Check if executable
    if [[ -x "$APP_PATH" ]]; then
        echo -e "  ${GREEN}✓${NC} Executable"
    else
        echo -e "  ${RED}✗${NC} Not executable!"
    fi
    # Check file type
    echo "  File info: $(file -b "$APP_PATH")"
fi
echo

# 4. Check allowed origins in manifest
echo "4. Checking allowed origins in manifest:"
if [[ -f "$ARC_MANIFEST" ]]; then
    ALLOWED_ORIGINS=$(python3 -c "
import json
with open('$ARC_MANIFEST') as f:
    data = json.load(f)
    if 'allowed_origins' in data:
        for origin in data['allowed_origins']:
            print(origin)
" 2>/dev/null)
    
    if [[ -n "$ALLOWED_ORIGINS" ]]; then
        echo "   Allowed origins:"
        echo "$ALLOWED_ORIGINS" | while read -r origin; do
            echo "   - $origin"
            if [[ "$origin" == *"$EXTENSION_ID"* ]]; then
                echo -e "     ${GREEN}✓${NC} Matches your extension ID"
            fi
        done
    else
        echo -e "   ${RED}✗${NC} No allowed_origins found!"
    fi
fi
echo

# 5. Test direct execution
echo "5. Testing direct native app execution:"
echo "   Running: $APP_PATH chrome-extension://$EXTENSION_ID/"
# Use gtimeout on macOS if available, otherwise skip timeout
if command -v gtimeout &> /dev/null; then
    TIMEOUT_CMD="gtimeout 2"
elif command -v timeout &> /dev/null; then
    TIMEOUT_CMD="timeout 2"
else
    TIMEOUT_CMD=""
fi

if [[ -n "$TIMEOUT_CMD" ]]; then
    if $TIMEOUT_CMD "$APP_PATH" "chrome-extension://$EXTENSION_ID/" > /tmp/octarine_test_output.txt 2>&1; then
        echo -e "   ${GREEN}✓${NC} App starts successfully"
    else
        EXIT_CODE=$?
        if [[ $EXIT_CODE -eq 124 ]]; then
            echo -e "   ${GREEN}✓${NC} App starts (timed out waiting for input - normal for native messaging)"
        else
            echo -e "   ${RED}✗${NC} App failed to start (exit code: $EXIT_CODE)"
            echo "   Error output:"
            cat /tmp/octarine_test_output.txt | head -10 | sed 's/^/     /'
        fi
    fi
else
    # No timeout command available, just run briefly
    "$APP_PATH" "chrome-extension://$EXTENSION_ID/" > /tmp/octarine_test_output.txt 2>&1 &
    APP_PID=$!
    sleep 1
    if ps -p $APP_PID > /dev/null 2>&1; then
        echo -e "   ${GREEN}✓${NC} App starts (running in native messaging mode)"
        kill $APP_PID 2>/dev/null
    else
        echo -e "   ${YELLOW}!${NC} App exited quickly (check output)"
        cat /tmp/octarine_test_output.txt | head -10 | sed 's/^/     /'
    fi
fi
echo

# 6. Test with Python script
echo "6. Testing native messaging with Python script:"
if [[ -f "test-native-messaging.py" ]]; then
    echo "   Running test-native-messaging.py..."
    python3 test-native-messaging.py 2>&1 | sed 's/^/   /'
else
    echo -e "   ${YELLOW}!${NC} test-native-messaging.py not found"
fi
echo

# 7. Check system logs
echo "7. Checking system logs for errors:"
echo "   Recent Chrome/Arc native messaging errors:"
log show --predicate 'process == "Arc" OR process == "Google Chrome" OR process == "OctarineMenubar"' --info --last 5m 2>/dev/null | grep -i "native" | tail -5 | sed 's/^/   /'

echo
echo "=== Diagnostic Summary ==="

# Generate summary
ISSUES=0

if [[ ! -f "$ARC_MANIFEST" ]] && [[ ! -f "$CHROME_MANIFEST" ]]; then
    echo -e "${RED}✗${NC} No native messaging manifest found"
    ((ISSUES++))
fi

if [[ ! -x "$APP_PATH" ]]; then
    echo -e "${RED}✗${NC} Native app not found or not executable"
    ((ISSUES++))
fi

if [[ -f "$ARC_MANIFEST" ]] && ! grep -q "$EXTENSION_ID" "$ARC_MANIFEST" 2>/dev/null; then
    echo -e "${YELLOW}!${NC} Extension ID might not be in allowed_origins"
    ((ISSUES++))
fi

if [[ $ISSUES -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} All basic checks passed!"
    echo
    echo "If native messaging still fails, try:"
    echo "1. Reload the extension in chrome://extensions"
    echo "2. Restart Arc/Chrome browser"
    echo "3. Check Console logs in the extension's background page"
else
    echo
    echo "Found $ISSUES potential issues. Please fix them and try again."
fi

# Cleanup
rm -f /tmp/octarine_test_output.txt