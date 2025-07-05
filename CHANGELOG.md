# Changelog

All notable changes to Octarine Extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial Chrome extension with Manifest V3
- Content extraction using Readability.js
- HTML to Markdown conversion with Turndown.js
- Metadata extraction from multiple sources
- Swift menubar app for macOS
- Native messaging between Chrome and Swift app
- Clipping management with YAML frontmatter
- Daily notes integration
- Pomodoro timer functionality
- Keyboard shortcut support (Cmd+Shift+S)
- Recent clippings view
- Installation script
- Comprehensive documentation

### Technical Details
- Chrome Extension:
  - Service worker background script
  - Content script for page extraction
  - Custom Turndown rules for better formatting
  - Metadata extraction from meta tags, Open Graph, and JSON-LD
  
- Swift App:
  - SwiftUI interface
  - Native messaging host implementation
  - File system management with sanitization
  - Background timer with notifications
  - Observable pattern for UI updates

### Known Issues
- Native messaging requires manual extension ID configuration
- No Windows/Linux support yet
- Limited to 1MB message size for native messaging
- Requires macOS 11.0 or later

## Example Future Releases

<!--
## [1.1.0] - 2025-02-01

### Added
- Search functionality across clippings
- Tag management system
- Export to PDF option
- Dark mode support

### Changed
- Improved content extraction for dynamic sites
- Better handling of code blocks
- Optimized file naming algorithm

### Fixed
- Unicode characters in filenames
- Memory leak in timer
- Native messaging timeout issues

## [1.0.1] - 2025-01-15

### Fixed
- Keyboard shortcut conflict with other extensions
- Daily note creation on first run
- Special characters in YAML frontmatter

### Security
- Sanitized file paths to prevent directory traversal
-->

---

## Version Guidelines

### Version Numbers
- MAJOR version: Incompatible API changes
- MINOR version: New functionality (backwards compatible)
- PATCH version: Bug fixes (backwards compatible)

### Categories
- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Features to be removed
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security updates