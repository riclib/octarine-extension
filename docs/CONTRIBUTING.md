# Contributing to Octarine Extension

Thank you for your interest in contributing to Octarine Extension! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive criticism
- Respect differing viewpoints and experiences

## How to Contribute

### Reporting Issues

1. **Check existing issues** first to avoid duplicates
2. **Use issue templates** when available
3. **Include details**:
   - macOS version
   - Chrome version
   - Steps to reproduce
   - Expected vs actual behavior
   - Error messages/screenshots

### Suggesting Features

1. **Open a discussion** first for major features
2. **Provide use cases** and examples
3. **Consider implementation** complexity
4. **Check roadmap** for planned features

### Submitting Code

#### Setup Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/octarine-extension.git
   cd octarine-extension
   ```
3. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### Development Guidelines

##### Chrome Extension

1. **Follow existing patterns**:
   - Use async/await over callbacks
   - Add error handling
   - Include console logs for debugging

2. **Test on multiple sites**:
   - News sites (CNN, BBC)
   - Blogs (Medium, personal)
   - Documentation (MDN, GitHub)
   - Academic papers

3. **Validate manifest changes**:
   ```bash
   python3 -m json.tool chrome-extension/manifest.json
   ```

##### Swift App

1. **Follow Swift conventions**:
   - Use Swift API Design Guidelines
   - Prefer value types (structs)
   - Use optionals appropriately

2. **SwiftUI best practices**:
   - Use @ObservedObject/@StateObject correctly
   - Keep views small and focused
   - Extract reusable components

3. **Test file operations**:
   - Various filename characters
   - Long titles
   - Unicode content

#### Code Style

##### JavaScript
```javascript
// Use const/let, not var
const CONSTANTS_LIKE_THIS = 'value';
let variablesLikeThis = 'value';

// Async/await preferred
async function functionName() {
  try {
    const result = await someAsyncCall();
    return result;
  } catch (error) {
    console.error('Context:', error);
    throw error;
  }
}

// Document complex functions
/**
 * Extracts metadata from the page
 * @returns {Object} Metadata object with title, author, etc.
 */
function extractMetadata() {
  // Implementation
}
```

##### Swift
```swift
// Use meaningful names
struct ClipMetadata {  // Not: ClipMD or Metadata
    let title: String
    let author: String?  // Explicit optionals
}

// Error handling
enum ClippingError: Error {
    case invalidContent
    case saveFailed(String)
}

// Documentation
/// Saves a clipping to the file system
/// - Parameters:
///   - content: The markdown content
///   - metadata: Clipping metadata
/// - Throws: ClippingError if save fails
func saveClipping(content: String, metadata: ClipMetadata) throws {
    // Implementation
}
```

#### Commit Messages

Follow conventional commits:

```
feat: add support for code syntax highlighting
fix: handle special characters in filenames
docs: update installation instructions
refactor: extract metadata parsing logic
test: add content extraction tests
```

Format:
- Type: feat, fix, docs, style, refactor, test, chore
- Scope (optional): extension, swift-app, docs
- Description: imperative mood, lowercase

#### Testing

##### Manual Testing Checklist

- [ ] Extension loads without errors
- [ ] Keyboard shortcut works
- [ ] Content extracts correctly
- [ ] Metadata is complete
- [ ] Files save with correct names
- [ ] Daily note updates properly
- [ ] Timer functions work
- [ ] Recent clippings display

##### Automated Tests (Future)

```swift
// Example Swift test
func testFilenameSanitization() {
    let manager = ClippingManager()
    let input = "Test: File/Name*With<Invalid>Chars?"
    let expected = "Test- File-Name-With-Invalid-Chars-"
    XCTAssertEqual(manager.sanitizeFilename(input), expected)
}
```

### Pull Request Process

1. **Update documentation** for new features
2. **Test thoroughly** (see checklist)
3. **Keep PRs focused** - one feature/fix per PR
4. **Write descriptive PR text**:
   - What changes were made
   - Why they were needed
   - How to test them

#### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring

## Testing
- [ ] Tested on Chrome version: ___
- [ ] Tested on macOS version: ___
- [ ] Manual testing completed
- [ ] Edge cases considered

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
```

### Areas for Contribution

#### Good First Issues

1. **Add file extension validation**
2. **Improve error messages**
3. **Add keyboard shortcut customization**
4. **Create app icon**

#### Feature Ideas

1. **Export formats**: PDF, DOCX, HTML
2. **Search functionality**
3. **Tag management**
4. **Theme support**
5. **Sync capabilities**

#### Documentation Needs

1. **Video tutorials**
2. **Integration guides**
3. **API examples**
4. **Localization**

### Development Resources

#### Chrome Extension
- [Chrome Extension Docs](https://developer.chrome.com/docs/extensions/)
- [Manifest V3 Guide](https://developer.chrome.com/docs/extensions/mv3/)
- [Native Messaging](https://developer.chrome.com/docs/extensions/mv3/nativeMessaging/)

#### Swift/macOS
- [Swift.org](https://swift.org/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

#### Libraries
- [Readability.js](https://github.com/mozilla/readability)
- [Turndown](https://github.com/mixmark-io/turndown)
- [Yams](https://github.com/jpsim/Yams)

### Review Process

1. **Maintainers review** within 1 week
2. **Address feedback** promptly
3. **Be patient** with reviews
4. **Ask questions** if unclear

### Release Process

1. Version bump in manifest.json and Package.swift
2. Update CHANGELOG.md
3. Tag release: `git tag v1.2.3`
4. Create GitHub release with notes

### Questions?

- Open an issue for bugs
- Start a discussion for features
- Check existing docs first
- Be specific and provide context

Thank you for contributing to Octarine Extension!