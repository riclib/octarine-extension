# Development Guide

## Prerequisites

- macOS 11.0 or later
- Xcode 13+ or Swift 5.5+
- Google Chrome
- Python 3 with PIL/Pillow (for icon generation)

## Project Setup

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd octarine-extension

# Install Swift dependencies
cd swift-app/OctarineMenubar
swift package resolve
cd ../..
```

### 2. Chrome Extension Development

#### Loading the Extension

1. Open Chrome and navigate to `chrome://extensions`
2. Enable "Developer mode" (top right)
3. Click "Load unpacked"
4. Select the `chrome-extension` directory

#### Getting the Extension ID

After loading, Chrome will assign an ID (looks like `abcdefghijklmnopqrstuvwxyz123456`). You'll need this for native messaging setup.

#### Debugging

- **Background Script**: Click "service worker" link in extension card
- **Content Script**: Use regular Chrome DevTools on any page
- **Popup**: Right-click extension icon → "Inspect popup"

#### Making Changes

After modifying extension files:
1. Go to `chrome://extensions`
2. Click the refresh icon on your extension card

### 3. Swift App Development

#### Building for Development

```bash
cd swift-app/OctarineMenubar
swift build
swift run  # Runs the app directly
```

#### Xcode Development

To use Xcode:
```bash
cd swift-app/OctarineMenubar
swift package generate-xcodeproj
open OctarineMenubar.xcodeproj
```

#### Debugging Native Messaging

1. Run the app from Terminal to see stdout/stderr:
   ```bash
   /Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar
   ```

2. Test native messaging manually:
   ```bash
   # Send a test message (4-byte length header + JSON)
   echo -n '{"type":"clip","content":"Test","metadata":{"title":"Test"}}' | \
   python3 -c "import sys,struct;msg=sys.stdin.read();sys.stdout.buffer.write(struct.pack('I',len(msg))+msg.encode())" | \
   /Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar
   ```

3. Check Console.app for app logs

### 4. Native Messaging Setup

#### Manual Installation

1. Create the native messaging manifest:
   ```bash
   mkdir -p ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/
   cp swift-app/com.octarine.clipper.json ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/
   ```

2. Update the manifest with your extension ID:
   ```json
   {
     "allowed_origins": [
       "chrome-extension://YOUR_ACTUAL_EXTENSION_ID/"
     ]
   }
   ```

#### Troubleshooting Native Messaging

Common issues:
- **"Native host has exited"**: Check app path in manifest
- **No response**: Verify message format (4-byte header)
- **Permission denied**: Check file permissions on app

## Code Organization

### Chrome Extension Structure

```
chrome-extension/
├── manifest.json         # Extension configuration
├── js/
│   ├── background.js    # Service worker, handles messaging
│   ├── content.js       # Runs in page context, extracts content
│   └── popup.js         # Popup UI logic
├── css/
│   └── popup.css        # Popup styling
├── lib/                 # Third-party libraries
│   ├── Readability.js   # Mozilla's readability
│   └── turndown.js      # HTML to Markdown
├── images/              # Extension icons
└── popup.html           # Popup UI
```

### Swift App Structure

```
swift-app/OctarineMenubar/
├── Package.swift                    # SPM configuration
└── Sources/
    ├── OctarineApp.swift           # App entry, menubar setup
    ├── Models/
    │   └── ClipMetadata.swift      # Data structures
    ├── Managers/
    │   ├── NativeMessagingHost.swift   # Chrome communication
    │   ├── ClippingManager.swift       # File I/O
    │   └── PomodoroTimer.swift         # Timer logic
    └── Views/
        └── ContentView.swift           # SwiftUI interface
```

## Testing

### Chrome Extension Testing

1. **Content Extraction**: Test on various websites
   - News articles (CNN, BBC, etc.)
   - Blog posts (Medium, personal blogs)
   - Documentation sites
   - Paywalled content (should fail gracefully)

2. **Metadata Extraction**: Verify all fields
   ```javascript
   // Test in console
   const meta = document.querySelector('meta[name="author"]');
   console.log(meta?.content);
   ```

3. **Keyboard Shortcut**: Test Cmd+Shift+S on different pages

### Swift App Testing

1. **File Operations**:
   ```swift
   // Test file saving
   let testMetadata = ClipMetadata(...)
   try clippingManager.saveClipping(content: "Test", metadata: testMetadata)
   ```

2. **Native Messaging**:
   - Send various message formats
   - Test error responses
   - Verify timeout handling

3. **UI Testing**:
   - Timer state transitions
   - Clipping list updates
   - Notification delivery

## Building for Release

### Chrome Extension

1. Update version in `manifest.json`
2. Create a ZIP file:
   ```bash
   cd chrome-extension
   zip -r ../octarine-extension.zip . -x "*.DS_Store"
   ```

### Swift App

1. Build for release:
   ```bash
   cd swift-app/OctarineMenubar
   swift build -c release
   ```

2. Create app bundle:
   ```bash
   ./install.sh  # This handles app bundle creation
   ```

3. Code sign (optional):
   ```bash
   codesign --deep --force --verify --verbose \
     --sign "Developer ID" \
     /Applications/OctarineMenubar.app
   ```

## Common Development Tasks

### Adding New Metadata Fields

1. Update Chrome extension (`content.js`):
   ```javascript
   metadata.newField = extractNewField();
   ```

2. Update Swift model (`ClipMetadata.swift`):
   ```swift
   let newField: String?
   ```

3. Update YAML frontmatter generation

### Modifying Markdown Conversion

Add custom Turndown rules in `content.js`:
```javascript
turndownService.addRule('customRule', {
  filter: 'element',
  replacement: function(content, node) {
    return `custom ${content}`;
  }
});
```

### Adding Menu Items

In `OctarineApp.swift`, modify the menu:
```swift
if let button = statusItem?.button {
  let menu = NSMenu()
  menu.addItem(NSMenuItem(title: "New Item", action: #selector(newAction), keyEquivalent: ""))
  statusItem?.menu = menu
}
```

## Performance Profiling

### Chrome Extension

Use Chrome DevTools Performance tab:
1. Start recording
2. Trigger content extraction
3. Analyze timeline

### Swift App

Use Instruments:
1. Build with release optimizations
2. Profile with Time Profiler
3. Check for memory leaks

## Debugging Tips

1. **Enable verbose logging**:
   ```swift
   // In Swift
   print("[ClippingManager] Saving to: \(fileURL)")
   ```
   
   ```javascript
   // In JavaScript
   console.log('[Content] Extracted metadata:', metadata);
   ```

2. **Check message flow**:
   - Chrome DevTools → Network → WS tab for native messaging
   - Console.app for Swift app logs

3. **Common issues**:
   - Extension not loading: Check manifest syntax
   - Native messaging fails: Verify paths and permissions
   - Files not saving: Check sandboxing and paths