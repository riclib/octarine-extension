# Octarine Extension

A Chrome extension paired with a macOS menubar app for clipping web pages as markdown to your local notes system.

## Features

- 📋 **Web Clipping**: Convert web pages to clean markdown using Mozilla's Readability
- 🗂️ **Organized Storage**: Clips saved to `~/Documents/Octarine/clippings/` with YAML frontmatter
- 📝 **Daily Notes Integration**: References automatically added to daily notes
- 🍅 **Pomodoro Timer**: Built-in timer in the menubar app for focused work sessions
- ⌨️ **Keyboard Shortcuts**: Quick clip with Cmd+Shift+S

## Quick Start

1. Clone this repository
2. Run the installation script: `./install.sh`
3. Follow the prompts to complete setup

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