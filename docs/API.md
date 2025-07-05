# API Documentation

## Chrome Extension APIs

### Background Script API

#### `clipCurrentPage()`
Initiates the clipping process for the current active tab.

**Returns**: `Promise<{success: boolean, error?: string, message?: string}>`

**Example**:
```javascript
const result = await clipCurrentPage();
if (result.success) {
  console.log(result.message);
} else {
  console.error(result.error);
}
```

#### `sendToNativeApp(data)`
Sends extracted content to the native messaging host.

**Parameters**:
- `data`: Object containing clip data
  - `type`: "clip"
  - `content`: Markdown content string
  - `metadata`: Metadata object

**Returns**: `Promise<{success: boolean, error?: string, message?: string}>`

### Content Script API

#### `extractPageContent()`
Extracts content and metadata from the current page.

**Returns**: `Promise<{data?: object, error?: string}>`

**Response Structure**:
```javascript
{
  data: {
    type: "clip",
    content: "# Article Title\n\nContent...",
    metadata: {
      title: "Article Title",
      url: "https://example.com",
      author: "Jane Doe",
      keywords: ["tech", "web"],
      date: "2025-01-05T10:00:00Z",
      excerpt: "Article summary..."
    }
  }
}
```

#### `extractMetadata()`
Extracts metadata from various page sources.

**Returns**: Metadata object
```javascript
{
  title: string,
  author: string | null,
  keywords: string[],
  description: string | null,
  publishedDate: string | null
}
```

#### `addCustomTurndownRules(turndownService)`
Adds custom conversion rules for better markdown output.

**Parameters**:
- `turndownService`: TurndownService instance

**Custom Rules Added**:
- `fencedCodeBlock`: Preserves language in code blocks
- `figure`: Handles images with captions

## Swift App APIs

### ClippingManager

#### `saveClipping(content: String, metadata: ClipMetadata)`
Saves a clipping to the file system.

**Parameters**:
- `content`: Markdown content
- `metadata`: ClipMetadata object

**Throws**: Error if save fails

**Example**:
```swift
let metadata = ClipMetadata(
    title: "Example Article",
    url: "https://example.com",
    author: "John Doe",
    keywords: ["swift", "ios"],
    date: "2025-01-05T10:00:00Z",
    excerpt: nil
)

try clippingManager.saveClipping(
    content: "Article content...",
    metadata: metadata
)
```

#### `sanitizeFilename(_ filename: String) -> String`
Cleans a string for use as a filename.

**Parameters**:
- `filename`: Original filename

**Returns**: Sanitized filename (max 50 chars, no invalid characters)

**Rules**:
- Removes: `:`, `/`, `\`, `?`, `%`, `*`, `|`, `"`, `<`, `>`
- Replaces with: `-`
- Truncates to 50 characters

### ClipMetadata

#### Properties
```swift
struct ClipMetadata {
    let title: String
    let url: String
    let author: String?
    let keywords: [String]
    let date: String
    let excerpt: String?
    let clippedAt: Date  // Auto-set to current date
}
```

#### `yamlFrontmatter: String`
Computed property that generates YAML frontmatter.

**Example Output**:
```yaml
---
title: "Example Article"
url: "https://example.com"
date: 2025-01-05T10:00:00Z
author: "John Doe"
keywords: ["swift", "ios"]
clipped_at: 2025-01-05T14:32:00Z
---
```

### NativeMessagingHost

#### Message Format

**Incoming Message Structure**:
```swift
struct IncomingMessage {
    let type: String  // "clip"
    let content: String
    let metadata: [String: Any]
}
```

**Outgoing Response Structure**:
```swift
struct Response {
    let success: Bool
    let message: String?
    let error: String?
}
```

#### Protocol Details

1. **Message Length Header**: 4 bytes, little-endian
2. **Message Body**: UTF-8 encoded JSON
3. **Max Message Size**: 1MB (1,048,576 bytes)

### PomodoroTimer

#### Properties
```swift
@Published var timeRemaining: TimeInterval
@Published var isRunning: Bool
@Published var currentTask: String?
@Published var isWorkSession: Bool
```

#### Methods

##### `start()`
Starts the timer.

##### `pause()`
Pauses the timer.

##### `reset()`
Resets timer to full duration.

##### `skip()`
Skips to next session (work/break).

##### `setTask(_ task: String)`
Sets the current task name.

**Parameters**:
- `task`: Task description

#### Constants
```swift
let workDuration: TimeInterval = 25 * 60  // 25 minutes
let breakDuration: TimeInterval = 5 * 60  // 5 minutes
```

## File System Structure

### Directory Layout
```
~/Documents/Octarine/
├── clippings/
│   ├── 2025-01-05 10:30 Article Title.md
│   ├── 2025-01-05 14:32 Another Article.md
│   └── ...
└── daily/
    ├── 2025-01-04.md
    ├── 2025-01-05.md
    └── ...
```

### File Naming Convention

**Clippings**: `YYYY-MM-DD HH:mm Title.md`
- Date format: 24-hour time
- Title: Sanitized, max 50 characters
- Extension: Always `.md`

**Daily Notes**: `YYYY-MM-DD.md`
- Date format: ISO date
- Extension: Always `.md`

## Chrome Extension Messages

### Runtime Messages

#### Clip Page Message
```javascript
// From popup to background
chrome.runtime.sendMessage({ 
    action: 'clip' 
});
```

#### Extract Content Message
```javascript
// From background to content
chrome.tabs.sendMessage(tabId, { 
    action: 'extractContent' 
});
```

### Command API

**Keyboard Shortcut**: `clip-page`
- Default: Ctrl+Shift+S (Windows/Linux)
- Mac: Cmd+Shift+S

## Error Codes

### Chrome Extension Errors
- `READABILITY_FAILED`: Could not extract article content
- `NO_CONTENT`: Page has no extractable content
- `NATIVE_HOST_ERROR`: Communication with Swift app failed
- `TIMEOUT`: Operation timed out

### Swift App Errors
- `INVALID_MESSAGE`: Malformed native message
- `SAVE_FAILED`: Could not write file
- `DIRECTORY_ERROR`: Could not create directories
- `PARSE_ERROR`: JSON parsing failed

## Events

### Chrome Extension Events

#### `chrome.commands.onCommand`
Fired when keyboard shortcut is pressed.

#### `chrome.runtime.onMessage`
Handles internal extension messaging.

### Swift App Notifications

#### Timer Complete Notification
```swift
let notification = NSUserNotification()
notification.title = "Work session complete!"
notification.informativeText = "Time for a break."
notification.soundName = NSUserNotificationDefaultSoundName
```