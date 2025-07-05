# Octarine Extension Documentation

Welcome to the Octarine Extension documentation. This guide covers everything you need to know about using, developing, and contributing to the project.

## 📚 Documentation Index

### For Users
- **[User Guide](USER_GUIDE.md)** - Complete guide for installation and daily usage
- **[Troubleshooting](TROUBLESHOOTING.md)** - Solutions to common problems

### For Developers
- **[Architecture](ARCHITECTURE.md)** - System design and component overview
- **[Development Guide](DEVELOPMENT.md)** - Setup and development workflow
- **[API Documentation](API.md)** - Detailed API reference
- **[Contributing](CONTRIBUTING.md)** - Guidelines for contributors

### Project Info
- **[Changelog](../CHANGELOG.md)** - Version history and changes
- **[README](../README.md)** - Project overview

## 🚀 Quick Start

1. **Install**: Run `./install.sh`
2. **Load Extension**: Open chrome://extensions, load `chrome-extension` folder
3. **Start App**: Launch `/Applications/OctarineMenubar.app`
4. **Clip Pages**: Press Cmd+Shift+S on any webpage

## 🏗️ Architecture Overview

```
┌──────────────┐         ┌─────────────────┐         ┌──────────────┐
│    Chrome    │◀────────│   Extension     │────────▶│  Swift App   │
│   Browser    │ Content │  Background     │ Native  │   Menubar    │
│              │ Script  │    Worker       │ Message │              │
└──────────────┘         └─────────────────┘         └──────────────┘
                                                             │
                                                             ▼
                                                      ┌──────────────┐
                                                      │ File System  │
                                                      │  ~/Octarine  │
                                                      └──────────────┘
```

## 📁 Project Structure

```
octarine-extension/
├── chrome-extension/      # Chrome extension files
│   ├── manifest.json     # Extension configuration
│   ├── js/              # Extension scripts
│   ├── lib/             # Third-party libraries
│   └── images/          # Icons and assets
├── swift-app/           # macOS menubar application
│   └── OctarineMenubar/ # Swift package
├── docs/                # Documentation
└── install.sh          # Installation script
```

## 🔑 Key Features

- **📋 Web Clipping**: Extract articles as clean markdown
- **🗂️ Organization**: Automatic file naming and frontmatter
- **📝 Daily Notes**: Integration with daily note system
- **🍅 Pomodoro Timer**: Built-in productivity timer
- **⌨️ Shortcuts**: Quick clip with Cmd+Shift+S

## 🛠️ Technology Stack

### Chrome Extension
- Manifest V3
- Readability.js for content extraction
- Turndown.js for markdown conversion
- Native Messaging API

### Swift App
- SwiftUI for interface
- Swift Package Manager
- Native messaging host
- FileManager for I/O

## 📊 Data Flow

1. **User triggers clip** (shortcut or button)
2. **Content script extracts** article and metadata
3. **Background script sends** to native app
4. **Swift app saves** to filesystem
5. **Daily note updated** with reference

## 🔍 Code Examples

### Clipping a Page (JavaScript)
```javascript
// From background.js
async function clipCurrentPage() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  const response = await chrome.tabs.sendMessage(tab.id, { action: 'extractContent' });
  return sendToNativeApp(response.data);
}
```

### Saving a Clipping (Swift)
```swift
// From ClippingManager.swift
func saveClipping(content: String, metadata: ClipMetadata) throws {
  let filename = "\(dateString) \(sanitizedTitle).md"
  let fullContent = metadata.yamlFrontmatter + content
  try fullContent.write(to: clippingsURL.appendingPathComponent(filename))
}
```

## 🧪 Testing

### Manual Testing
- Load extension in Chrome developer mode
- Run Swift app from Xcode or Terminal
- Test on various websites
- Verify file creation

### Debug Commands
```bash
# Watch for new clippings
fswatch ~/Documents/Octarine/clippings/

# View app logs
log stream --predicate 'process == "OctarineMenubar"'

# Test native messaging
cat test-message.json | /Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:
- Code style
- Pull request process
- Development setup
- Testing requirements

## 📄 License

This project is licensed under the MIT License. See LICENSE file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](.github/ISSUE_TEMPLATE/)
- **Discussions**: GitHub Discussions
- **Documentation**: You're here!

## 🔗 Related Projects

- [Readability.js](https://github.com/mozilla/readability) - Content extraction
- [Turndown](https://github.com/mixmark-io/turndown) - HTML to Markdown
- [Obsidian](https://obsidian.md) - Note-taking app (compatible format)