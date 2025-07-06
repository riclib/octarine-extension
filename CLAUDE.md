# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

### Chrome Extension
```bash
# No build needed - directly load in Chrome
# chrome://extensions → Developer mode → Load unpacked → select chrome-extension/

# After making changes to extension files:
# Click refresh icon on extension card in chrome://extensions
```

### Swift App
```bash
# Build development version
cd swift-app/OctarineMenubar
swift build

# Build release version
swift build -c release

# Run directly
swift run

# Generate Xcode project
swift package generate-xcodeproj
```

### Installation
```bash
# Full installation (prompts for extension ID)
./install.sh

# Manual native messaging setup
cp swift-app/com.octarine.clipper.json ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/
# Then edit the file to replace YOUR_EXTENSION_ID_HERE with actual extension ID
```

### Testing Native Messaging
```bash
# Test message sending to Swift app
echo -n '{"type":"clip","content":"Test","metadata":{"title":"Test"}}' | \
python3 -c "import sys,struct;msg=sys.stdin.read();sys.stdout.buffer.write(struct.pack('I',len(msg))+msg.encode())" | \
/Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar

# Monitor Swift app logs
log stream --predicate 'process == "OctarineMenubar"'

# Watch for new clippings
fswatch ~/Documents/Octarine/clippings/
```

## Architecture Overview

This is a two-component system that clips web pages to local markdown files:

1. **Chrome Extension** (Manifest V3)
   - `background.js`: Service worker handling keyboard shortcuts, native messaging, and badge notifications
   - `content.js`: Extracts page content using Readability.js and converts to markdown with Turndown.js
   - Badge notifications: Shows `...` while processing, `✓` on success, `!` on error
   - Communicates with Swift app via Chrome Native Messaging API

2. **Swift Menubar App**
   - `OctarineApp.swift`: Single-instance architecture with distributed notifications for IPC
   - `NativeMessagingHost.swift`: Reads messages from stdin, stays resident after Chrome disconnects
   - `ClippingManager.swift`: Saves files to `~/Documents/Octarine/clippings/` with YAML frontmatter
   - `PomodoroTimer.swift`: Additional productivity timer feature
   - Updates daily notes in `~/Documents/Octarine/daily/`
   - UI includes quit button (X icon) in top-right corner

### Data Flow
1. User presses Cmd+Shift+S or clicks extension icon
2. Content script extracts article content and metadata
3. Background script sends JSON message to Swift app via native messaging
4. Swift app saves markdown file with frontmatter and updates daily note

### Message Format
```json
{
  "type": "clip",
  "content": "# Markdown content...",
  "metadata": {
    "title": "Page Title",
    "url": "https://example.com",
    "author": "Author Name",
    "keywords": ["tag1", "tag2"],
    "date": "2025-01-05T10:00:00Z",
    "excerpt": "Summary..."
  }
}
```

### File Naming
- Clippings: `YYYY-MM-DD HH:mm Title.md` (sanitized title, max 50 chars)
- Daily notes: `YYYY-MM-DD.md`

## Key Implementation Details

- **Extension ID**: Must be manually configured in `com.octarine.clipper.json` after loading extension
- **Native Messaging**: Uses stdin/stdout with 4-byte little-endian length header
- **Single Instance**: App forwards messages via distributed notifications if already running
- **Content Extraction**: Readability.js for article extraction, custom Turndown rules for markdown
- **Metadata Sources**: Meta tags, Open Graph, JSON-LD, with fallbacks
- **File Sanitization**: Removes `:/?%*|"<>\` from filenames, replaces with `-`
- **Success Indicator**: Menubar icon shows checkmark for 2 seconds after successful clip
- **Error Handling**: Native messaging errors are common - check Console.app and extension ID

## Common Issues

- **"Native host has exited"**: Less common now (app stays resident), but check extension ID in manifest
- **No clippings saved**: Check if Swift app is running and has write permissions
- **Multiple app instances**: Kill all with `pkill OctarineMenubar` and restart
- **Content extraction fails**: Some dynamic sites need manual text selection