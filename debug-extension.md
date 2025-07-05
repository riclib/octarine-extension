# Debugging the Extension

Since all native messaging components are correctly installed, let's debug from the extension side:

## 1. Check Extension Console

1. Open Arc browser
2. Go to `chrome://extensions/`
3. Find "Octarine Web Clipper"
4. Click on "background page" or "service worker" under "Inspect views"
5. This opens the Developer Console for the extension
6. Try clipping a page (Cmd+Shift+S or click the extension icon)
7. Look for any error messages in the console

## 2. Things to Look For

In the extension's console, you should see messages like:
- `[Octarine] Starting clipCurrentPage`
- `[Octarine] Active tab: <URL>`
- `Sending to native app: {host: "com.octarine.clipper", ...}`

If you see "Native messaging error", check the full error details.

## 3. Possible Issues and Fixes

### Issue: "Specified native messaging host not found"
- **Fix**: Restart Arc browser completely (Cmd+Q, then reopen)

### Issue: Extension shows old code
- **Fix**: 
  1. Go to chrome://extensions/
  2. Click the refresh icon on the Octarine extension
  3. Or toggle the extension off and on

### Issue: Permissions not granted
- **Fix**: 
  1. Click on the extension icon
  2. Click on "This can read and change site data"
  3. Select "On all sites" or "When you click the extension"

## 4. Test Sequence

1. Open a simple webpage (like https://example.com)
2. Open the extension's background console
3. Press Cmd+Shift+S or click the extension icon
4. Watch the console for messages

## 5. Force Reload Everything

If still having issues:
```bash
# 1. Quit Arc completely
osascript -e 'quit app "Arc"'

# 2. Clear extension storage (optional)
rm -rf "$HOME/Library/Application Support/Arc/Default/Extension State"

# 3. Restart Arc
open -a "Arc"

# 4. Reload the extension
# Go to chrome://extensions/ and click reload
```

## 6. Alternative Test

Try this in the extension's console:
```javascript
// Test native messaging directly
chrome.runtime.sendNativeMessage('com.octarine.clipper', 
  {type: 'test', content: 'Hello from console'}, 
  response => {
    if (chrome.runtime.lastError) {
      console.error('Error:', chrome.runtime.lastError);
    } else {
      console.log('Response:', response);
    }
  }
);
```