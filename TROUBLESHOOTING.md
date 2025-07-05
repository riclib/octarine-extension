# Octarine Extension Troubleshooting Guide

## Current Status
- ✅ Native messaging manifest is correctly installed in Arc directory
- ✅ Extension ID matches the allowed origins 
- ✅ Native app executes successfully when tested manually
- ✅ Python test script can communicate with the native app
- ❌ Extension shows "Native messaging error" when clipping

## Next Steps to Debug

### 1. Reload the Extension with Debug Code
1. Open Arc browser
2. Go to `chrome://extensions/`
3. Find "Octarine Web Clipper" and click the refresh icon
4. The extension now has enhanced debugging

### 2. Open Extension Console
1. On the extensions page, click "service worker" under the Octarine extension
2. This opens the Developer Console for the extension
3. Keep this console open

### 3. Test Clipping
1. Go to any webpage (e.g., https://example.com)
2. Press Cmd+Shift+S or click the extension icon
3. Watch the console for debug messages

### 4. What to Look For

You should see messages like:
```
🔍 [Native Message Debug]
  Application: com.octarine.clipper
  Message preview: {"type":"clip","content":"...
  Message size: 1234 bytes
```

If you see an error, it will show:
```
  ❌ Error object: {message: "..."}
  Error message: <specific error>
```

### 5. Common Errors and Solutions

#### "Specified native messaging host not found"
- Solution: Restart Arc completely (Cmd+Q) and try again

#### "Native host has exited"
- The app crashed. Check Console.app for crash logs

#### No error but no response
- The app might be hanging. Check Activity Monitor

### 6. Manual Test in Extension Console

Open the extension's console and run:
```javascript
// Direct test
chrome.runtime.sendNativeMessage('com.octarine.clipper', 
  {type: 'test', content: 'Hello'}, 
  response => {
    console.log('Response:', response);
    if (chrome.runtime.lastError) {
      console.error('Error:', chrome.runtime.lastError);
    }
  }
);
```

### 7. If All Else Fails

1. **Complete Reset**:
   ```bash
   # Remove all traces
   rm -rf "$HOME/Library/Application Support/Arc/User Data/NativeMessagingHosts/com.octarine.clipper.json"
   rm -rf /Applications/OctarineMenubar.app
   
   # Reinstall
   ./install.sh
   ```

2. **Check Arc Settings**:
   - Go to Arc Settings
   - Search for "extensions" or "developer"
   - Ensure developer mode is enabled

3. **Try in Chrome**:
   - Install the extension in Chrome to see if it's Arc-specific
   - The install script already set up Chrome support

## Debug Information to Collect

When reporting issues, provide:
1. The full console output from the extension
2. The output of `./diagnose-native-messaging.sh`
3. Arc version (Arc menu > About Arc)
4. macOS version
5. Any errors in Console.app filtered by "OctarineMenubar"