# Octarine Extension User Guide

## Installation

### Quick Install

1. Run the installation script:
   ```bash
   ./install.sh
   ```

2. When prompted, enter your Chrome extension ID (found in chrome://extensions after loading the extension)

3. The installer will:
   - Build the Swift menubar app
   - Install it to `/Applications/OctarineMenubar.app`
   - Configure native messaging

**Note**: The app uses a single-instance architecture. If Chrome launches it for clipping, it will stay running as a menubar app afterwards. This ensures consistent behavior and prevents multiple instances.

### Manual Installation

#### Chrome Extension

1. Open Chrome and go to `chrome://extensions`
2. Enable "Developer mode" (toggle in top right)
3. Click "Load unpacked"
4. Select the `chrome-extension` folder from this project
5. Note the extension ID shown on the extension card

#### Swift Menubar App

1. Build the app:
   ```bash
   cd swift-app/OctarineMenubar
   swift build -c release
   ```

2. Copy to Applications:
   ```bash
   cp -r .build/release/OctarineMenubar /Applications/
   ```

3. Configure native messaging:
   - Edit `swift-app/com.octarine.clipper.json`
   - Replace `YOUR_EXTENSION_ID_HERE` with your actual extension ID
   - Copy to Chrome's native messaging directory:
     ```bash
     cp com.octarine.clipper.json ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/
     ```

## Usage

### Clipping Web Pages

#### Method 1: Keyboard Shortcut
Press **Cmd+Shift+S** on any webpage to clip it instantly.

#### Method 2: Extension Icon
Click the Octarine extension icon in Chrome toolbar to clip instantly.

#### Visual Feedback
The extension icon shows badge notifications:
- `...` badge while processing
- `✓` badge when successfully clipped
- `!` badge if an error occurs

#### What Gets Saved

Each clipping includes:
- **Content**: Clean, readable markdown (ads and navigation removed)
- **Metadata**: Title, author, URL, publish date, keywords
- **Location**: `~/Documents/Octarine/clippings/`
- **Filename**: `2025-01-05 14:32 Article Title.md`

### Using the Menubar App

Click the Octarine icon in your Mac's menubar to access:

**Note**: When a clipping is saved successfully, the menubar icon briefly changes to a checkmark for 2 seconds as visual confirmation.

To quit the app, click the X button in the top-right corner of the popover.

#### Timer Tab
- **Pomodoro Timer**: 25-minute work sessions, 5-minute breaks
- **Controls**: Play/pause, reset, skip to next session
- **Current Task**: Shows active task (if set from daily note)

#### Clippings Tab
- **Recent Clippings**: Last 10 saved articles
- **Quick Access**: Click arrow icon to open in default markdown editor
- **Metadata**: Shows date/time of clipping

### Daily Notes Integration

Clippings are automatically referenced in your daily notes:

1. Daily notes are stored in `~/Documents/Octarine/daily/`
2. Format: `YYYY-MM-DD.md`
3. Clippings added to "## Clippings" section
4. Format: `- HH:MM - [[clippings/Clipping Name]] - URL`

Example daily note:
```markdown
# Daily Note - 2025-01-05

## Tasks
- [ ] Review React documentation
- [ ] Write blog post

## Notes
Team meeting at 2pm about new feature

## Clippings
- 10:30 - [[clippings/2025-01-05 10:30 React Best Practices]] - https://example.com/react
- 14:32 - [[clippings/2025-01-05 14:32 Swift Concurrency Guide]] - https://swift.org/guide
```

### File Organization

Your Octarine folder structure:
```
~/Documents/Octarine/
├── clippings/          # All web clippings
│   ├── 2025-01-05 10:30 React Best Practices.md
│   └── 2025-01-05 14:32 Swift Concurrency Guide.md
└── daily/              # Daily notes
    ├── 2025-01-04.md
    └── 2025-01-05.md
```

## Features

### Smart Content Extraction

- **Reader Mode**: Extracts only the main article content
- **Code Preservation**: Maintains code blocks with syntax highlighting
- **Image Handling**: Preserves images with captions
- **Clean Formatting**: Removes ads, popups, navigation

### Metadata Extraction

The extension automatically extracts:
- Article title
- Author name (when available)
- Publication date
- Keywords/tags
- Article excerpt/summary
- Source URL

### Markdown Formatting

- **Headings**: Converted to proper markdown headers
- **Lists**: Maintains bullet and numbered lists
- **Links**: Preserved with proper markdown syntax
- **Code**: Fenced code blocks with language detection
- **Quotes**: Blockquotes properly formatted
- **Images**: With alt text and captions

### Pomodoro Timer

- **Work Sessions**: 25 minutes of focused work
- **Break Time**: 5 minutes to rest
- **Notifications**: System alerts when sessions complete
- **Task Tracking**: Link current task to daily note items

## Tips & Tricks

### Best Practices

1. **Review Before Clipping**: The extension works best on article-style content
2. **Organize with Tags**: Add keywords in your daily notes for easier searching
3. **Use with Obsidian**: The markdown format and wiki-links work great with Obsidian
4. **Keyboard Shortcuts**: Cmd+Shift+S is fastest for frequent clipping

### Troubleshooting

#### Extension Not Working

1. Check if the menubar app is running (look for the icon in your menubar)
2. If multiple instances might be running, quit all and restart:
   ```bash
   pkill OctarineMenubar
   open /Applications/OctarineMenubar.app
   ```
3. Verify extension has necessary permissions
4. Try reloading the extension in chrome://extensions

#### Clippings Not Saving

1. Ensure Octarine menubar app is running
2. Check `~/Documents/Octarine/` exists and is writable
3. Look for errors in Console.app

#### Native Messaging Errors

1. Verify extension ID matches in manifest
2. Check native messaging host is installed:
   ```bash
   ls ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/
   ```
3. Ensure app path in manifest is correct

### Advanced Usage

#### Custom Templates

Edit clipping format by modifying the frontmatter in `ClipMetadata.swift`

#### Integration with Other Apps

- **Obsidian**: Wiki-links work automatically
- **Notion**: Import markdown files
- **Bear**: Drag and drop markdown files
- **VS Code**: Open Octarine folder as workspace

#### Automation

Create shortcuts or scripts to:
- Open today's daily note
- Search clippings by date
- Export clippings to other formats

## Privacy & Security

- **Local Only**: All data stays on your computer
- **No Analytics**: No tracking or data collection
- **Open Source**: Inspect the code yourself
- **Sandboxed**: Swift app runs with limited permissions

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Clip current page | Cmd+Shift+S |
| Clip current page (alt) | Click extension icon |
| Quit menubar app | Click X in popover |
| Start/pause timer | Click play button |
| Reset timer | Click reset button |
| Skip session | Click forward button |

## FAQ

**Q: Can I change the save location?**
A: Currently set to `~/Documents/Octarine/`. You can modify this in `ClippingManager.swift`.

**Q: Does it work with paywalled content?**
A: Only content visible in your browser can be clipped.

**Q: Can I clip PDFs?**
A: Currently optimized for HTML content. PDF support may come in future.

**Q: How do I uninstall?**
A: Remove the extension from Chrome, delete `/Applications/OctarineMenubar.app`, and remove the native messaging manifest.

**Q: Can I sync across devices?**
A: Store your Octarine folder in iCloud Drive or Dropbox for syncing.