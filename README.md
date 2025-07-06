# Octarine Extension

A Chrome extension paired with a macOS menubar app for clipping web pages as markdown to your local notes system.

## Features

- 📋 **Web Clipping**: Convert web pages to clean markdown using Mozilla's Readability
- 🗂️ **Organized Storage**: Clips saved to `~/Documents/Octarine/clippings/` with YAML frontmatter
- 📝 **Daily Notes Integration**: References automatically added to daily notes
- 🍅 **Pomodoro Timer**: Built-in timer in the menubar app for focused work sessions
- ⌨️ **Keyboard Shortcuts**: Quick clip with Cmd+Shift+S
- 🔔 **Badge Notifications**: Visual feedback on the extension icon

## Prerequisites

- macOS 11.0 or later
- Google Chrome
- Swift 5.5+ (comes with Xcode or Command Line Tools)
- Git

### Installing Swift (if needed)
```bash
# Option 1: Install Xcode Command Line Tools (smaller download)
xcode-select --install

# Option 2: Install Xcode from the App Store (full IDE)
```

## Quick Start

📚 **[Jump to 5-minute Quick Start Guide](QUICK_START.md)** for the fastest setup!

### Full Installation Steps

1. **Clone this repository**
   ```bash
   git clone https://github.com/riclib/octarine-extension.git
   cd octarine-extension
   chmod +x install.sh
   ```

2. **Load the Chrome extension FIRST**
   - Open Chrome and go to `chrome://extensions`
   - Enable "Developer mode" (toggle in top right)
   - Click "Load unpacked"
   - Select the `chrome-extension` folder from this project
   - **Copy the Extension ID** shown on the extension card (you'll need this!)

3. **Run the installer**
   ```bash
   ./install.sh
   ```
   - Paste the Extension ID when prompted
   - The installer will build and set up everything

4. **Start using Octarine**
   - The menubar app icon should appear in your Mac's menu bar
   - Press `Cmd+Shift+S` on any webpage to clip it
   - Or click the extension icon in Chrome

## Verification

After installation, verify everything is working:
1. Look for the Octarine icon in your menubar (document icon)
2. Try clipping a webpage with `Cmd+Shift+S`
3. Check `~/Documents/Octarine/clippings/` for the saved file
4. Click the menubar icon to see recent clippings

## Important Notes

⚠️ **Extension ID Changes**: If you remove and reload the extension in Chrome, it gets a new ID. You'll need to run the installer again with the new ID.

📁 **File Locations**: 
- Clippings: `~/Documents/Octarine/clippings/`
- Daily notes: `~/Documents/Octarine/daily/`
- App: `/Applications/OctarineMenubar.app`

## Documentation

📚 **Full documentation is available in the [docs](docs/) directory:**

- **[User Guide](docs/USER_GUIDE.md)** - Installation and usage instructions
- **[Architecture](docs/ARCHITECTURE.md)** - System design and components
- **[Development](docs/DEVELOPMENT.md)** - Development setup and workflow
- **[API Reference](docs/API.md)** - Detailed API documentation
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Contributing](docs/CONTRIBUTING.md)** - How to contribute

## Project Structure

```
octarine-extension/
├── chrome-extension/     # Chrome extension files
│   ├── manifest.json    # Extension configuration
│   ├── js/             # Extension JavaScript
│   ├── lib/            # Third-party libraries
│   └── images/         # Extension icons
├── swift-app/          # macOS menubar app
│   └── OctarineMenubar/
│       └── Sources/    # Swift source files
├── docs/               # Documentation
│   ├── README.md      # Documentation index
│   ├── USER_GUIDE.md  # User documentation
│   ├── ARCHITECTURE.md # System architecture
│   ├── DEVELOPMENT.md # Developer guide
│   ├── API.md         # API reference
│   ├── TROUBLESHOOTING.md # Troubleshooting
│   └── CONTRIBUTING.md # Contribution guide
├── .github/            # GitHub templates
│   └── ISSUE_TEMPLATE/
└── install.sh          # Installation script
```

## How It Works

1. The Chrome extension extracts content from web pages using Readability.js
2. Content is converted to markdown using Turndown.js
3. Metadata (title, author, keywords, etc.) is extracted from the page
4. The extension sends the content to the Swift menubar app via native messaging
5. The menubar app saves the clipping with YAML frontmatter to your local filesystem
6. A reference is added to today's daily note

## File Format

Clippings are saved as markdown files with YAML frontmatter:

```markdown
---
title: "Article Title"
url: "https://example.com/article"
date: 2025-01-05T14:32:00Z
author: "John Doe"
keywords: ["productivity", "web"]
clipped_at: 2025-01-05T14:32:00Z
---

# Article Title

[Article content in markdown...]
```

## Troubleshooting

### Common Issues

**"Access to native messaging host forbidden"**
- Make sure you used the correct Extension ID from Chrome
- Try quitting Chrome completely and restarting
- Re-run the installer with the correct ID

**No menubar icon appears**
- Check if the app is already running: `ps aux | grep OctarineMenubar`
- Try launching manually: `open /Applications/OctarineMenubar.app`
- Check Console.app for error messages

**Clipping doesn't work**
- Verify the extension icon shows in Chrome's toolbar
- Check that the menubar app is running
- Try the keyboard shortcut `Cmd+Shift+S`
- Look for badge notifications on the extension icon

For more help, see the [Troubleshooting Guide](docs/TROUBLESHOOTING.md).

## Development

### Chrome Extension
- Load unpacked extension from `chrome-extension/` directory
- Enable Developer mode in Chrome

### Swift App
```bash
cd swift-app/OctarineMenubar
swift build
swift run
```

For detailed development instructions, see the [Development Guide](docs/DEVELOPMENT.md).

## Contributing

We welcome contributions! Please see our [Contributing Guide](docs/CONTRIBUTING.md) for details.

## Support

- **Documentation**: See the [docs](docs/) directory
- **Issues**: Use [GitHub Issues](.github/ISSUE_TEMPLATE/)
- **Troubleshooting**: Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)

## License

MIT