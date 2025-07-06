# Octarine Extension Architecture

## Overview

The Octarine Extension is a two-part system consisting of:
1. A Chrome extension for web content extraction
2. A macOS menubar app for file management and productivity features

Communication between the two components uses Chrome's Native Messaging API. The app uses a single-instance architecture with distributed notifications for inter-process communication.

## System Flow

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│                 │     │                  │     │                 │
│  Chrome Browser │────▶│ Content Script   │────▶│ Background      │
│  (User clicks)  │     │ (Readability.js) │     │ Script          │
│                 │     │                  │     │                 │
└─────────────────┘     └──────────────────┘     └────────┬────────┘
                                                           │
                                                           │ Native
                                                           │ Messaging
                                                           ▼
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│                 │     │                  │     │                 │
│   File System   │◀────│ ClippingManager  │◀────│ NativeMessaging │
│ (~/Documents/   │     │ (Swift)          │     │ Host (Swift)    │
│  Octarine/)     │     │                  │     │                 │
└─────────────────┘     └──────────────────┘     └─────────────────┘

Note: The Swift app implements single-instance architecture. When Chrome launches
the app, if an instance is already running, the new instance forwards the message
via distributed notifications and exits.
```

## Component Details

### Chrome Extension

#### Manifest (manifest.json)
- **Version**: Manifest V3
- **Permissions**: activeTab, storage, nativeMessaging
- **Background**: Service worker model
- **Content Scripts**: Run on all URLs to extract content

#### Background Script (js/background.js)
- Handles keyboard shortcuts (Cmd+Shift+S)
- Manages communication with content script
- Sends messages to native host
- Shows badge notifications on extension icon:
  - `...` while processing
  - `✓` on success
  - `!` on error
- Error handling and retry logic

#### Content Script (js/content.js)
- Extracts page content using Readability.js
- Extracts metadata from various sources:
  - Meta tags (author, keywords, description)
  - Open Graph tags
  - JSON-LD structured data
- Converts HTML to Markdown using Turndown.js
- Custom Turndown rules for better formatting

#### Libraries Used
- **Readability.js**: Mozilla's library for article extraction
- **Turndown.js**: HTML to Markdown converter

### Swift Menubar App

#### App Structure
```
OctarineMenubar/
├── Sources/
│   ├── OctarineApp.swift      # Main app entry point, single-instance logic
│   ├── Models/
│   │   └── ClipMetadata.swift # Data model for clippings
│   ├── Managers/
│   │   ├── NativeMessagingHost.swift  # Chrome communication
│   │   ├── ClippingManager.swift      # File operations
│   │   └── PomodoroTimer.swift        # Timer logic
│   └── Views/
│       └── ContentView.swift   # SwiftUI interface
└── Package.swift              # Swift Package Manager config
```

#### Key Components

**NativeMessagingHost.swift**
- Reads messages from stdin
- Parses Chrome's message format (4-byte length header + JSON)
- Sends responses back via stdout
- Returns gracefully when Chrome disconnects (app stays resident)
- Error handling for malformed messages

**OctarineApp.swift**
- Implements single-instance architecture
- First instance becomes the menubar app
- Subsequent instances forward messages via distributed notifications
- Shows success indicator (checkmark icon) for 2 seconds after clipping
- Includes quit button (X icon) in popover UI

**ClippingManager.swift**
- Creates directory structure on first run
- Saves clippings with YAML frontmatter
- Sanitizes filenames (removes invalid characters, limits length)
- Updates daily notes with references
- Maintains list of recent clippings

**ClipMetadata.swift**
- Data model for clipping metadata
- Generates YAML frontmatter
- Escapes special characters for YAML

**PomodoroTimer.swift**
- 25-minute work sessions, 5-minute breaks
- System notifications on completion
- Task tracking integration

## Data Formats

### Native Messaging Protocol

**Chrome → Swift Message**:
```json
{
  "type": "clip",
  "content": "# Article content in markdown...",
  "metadata": {
    "title": "Article Title",
    "url": "https://example.com",
    "author": "John Doe",
    "keywords": ["tech", "web"],
    "date": "2025-01-05T14:32:00Z",
    "excerpt": "Article summary..."
  }
}
```

**Swift → Chrome Response**:
```json
{
  "success": true,
  "message": "Clipping saved successfully"
}
```

### File Format

**Clipping files** (`~/Documents/Octarine/clippings/YYYY-MM-DD HH:mm Title.md`):
```markdown
---
title: "Article Title"
url: "https://example.com"
date: 2025-01-05T14:32:00Z
author: "John Doe"
keywords: ["tech", "web"]
clipped_at: 2025-01-05T14:32:00Z
excerpt: "Article summary..."
---

# Article Title

[Article content in markdown...]
```

**Daily notes** (`~/Documents/Octarine/daily/YYYY-MM-DD.md`):
```markdown
# Daily Note - 2025-01-05

## Tasks
- [ ] Review documentation
- [ ] Write tests

## Notes
Meeting notes here...

## Clippings
- 14:32 - [[clippings/2025-01-05 14:32 Article Title]] - https://example.com
- 16:45 - [[clippings/2025-01-05 16:45 Another Article]] - https://example.org
```

## Security Considerations

1. **Sandboxing**: Swift app runs sandboxed with limited permissions
2. **Input Validation**: All inputs sanitized before file operations
3. **Path Restrictions**: Files only saved to designated Octarine folders
4. **No Remote Access**: All operations are local only

## Error Handling

### Chrome Extension
- Graceful fallback if Readability fails
- Timeout handling for native messaging
- Badge notifications for user feedback (no popup required)

### Swift App
- Directory creation with error recovery
- File write error handling
- Malformed message rejection
- Single-instance conflict handling
- Logging to Console.app for debugging

## Performance Considerations

1. **Lazy Loading**: Recent clippings loaded on demand
2. **Efficient IPC**: Binary message format for native messaging
3. **Background Processing**: File operations on background queue
4. **Memory Management**: Proper cleanup of resources
5. **Single Instance**: Reduces resource usage by preventing duplicate processes