# Troubleshooting Guide

## Common Issues

### Chrome Extension Issues

#### Badge Notifications Not Showing

**Symptoms**: No visual feedback when clipping (no `...`, `✓`, or `!` badges)

**Solutions**:
1. Check if extension icon is visible in toolbar
2. Reload extension in chrome://extensions
3. Check browser console for errors
4. Ensure extension has proper permissions

#### Extension Not Loading

**Symptoms**: Extension doesn't appear in Chrome toolbar

**Solutions**:
1. Check Chrome version (must be recent)
2. Verify manifest.json syntax:
   ```bash
   python3 -m json.tool chrome-extension/manifest.json
   ```
3. Check for errors in chrome://extensions
4. Try removing and re-adding the extension

#### Keyboard Shortcut Not Working

**Symptoms**: Cmd+Shift+S doesn't clip the page

**Solutions**:
1. Check shortcut conflicts in chrome://extensions/shortcuts
2. Verify extension is enabled
3. Try setting a different shortcut
4. Ensure the page has finished loading

#### Content Not Extracting

**Symptoms**: Clipped content is empty or malformed

**Common Causes**:
- Dynamic content (SPA) not fully loaded
- Paywalled or login-required content
- Non-article content (dashboards, apps)

**Solutions**:
1. Wait for page to fully load
2. Try scrolling to load lazy content
3. Check if Readability.js supports the site
4. Manually select text before clipping

### Swift App Issues

#### App Not Starting

**Symptoms**: Menubar icon doesn't appear

**Solutions**:
1. Check if app is already running:
   ```bash
   ps aux | grep OctarineMenubar
   ```
2. Kill any existing instances:
   ```bash
   pkill OctarineMenubar
   ```
3. Check if app is in Applications folder
4. Verify macOS version (11.0+)
5. Look for crash logs in Console.app
6. Try running from Terminal:
   ```bash
   /Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar
   ```

#### Multiple App Instances

**Symptoms**: Changes not reflecting in UI, multiple menubar icons

**Solutions**:
1. Check for duplicate processes:
   ```bash
   ps aux | grep OctarineMenubar | grep -v grep
   ```
2. Kill all instances and restart:
   ```bash
   pkill OctarineMenubar
   open /Applications/OctarineMenubar.app
   ```
3. The app uses single-instance architecture, so this should be rare

#### Files Not Saving

**Symptoms**: Clippings don't appear in filesystem

**Solutions**:
1. Check directory permissions:
   ```bash
   ls -la ~/Documents/Octarine/
   ```
2. Verify disk space
3. Check Console.app for permission errors
4. Try creating directory manually:
   ```bash
   mkdir -p ~/Documents/Octarine/{clippings,daily}
   ```

### Native Messaging Issues

#### "Native host has exited" Error

**Symptoms**: Chrome shows native host error (less common now due to app persistence)

**Solutions**:
1. Verify manifest path:
   ```bash
   cat ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.octarine.clipper.json
   ```

2. Check app path in manifest is correct
3. Ensure extension ID matches:
   ```json
   "allowed_origins": ["chrome-extension://YOUR_ACTUAL_ID/"]
   ```

4. Test native messaging manually:
   ```bash
   # This should launch the app
   /Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar
   ```

#### No Response from Native App

**Symptoms**: Clipping appears to work but nothing is saved

**Debugging Steps**:
1. Run app from Terminal to see output
2. Check message format in Console.app
3. Verify JSON parsing:
   ```javascript
   // In Chrome console
   JSON.stringify({type: "clip", content: "test", metadata: {}})
   ```

### Debugging Tools

#### Chrome Extension Debugging

1. **Background Script Console**:
   - Go to chrome://extensions
   - Click "service worker" link
   - Check for errors in console

2. **Content Script Debugging**:
   - Open DevTools on any page
   - Look for errors in Console
   - Check Network tab for failed requests

3. **Enable Verbose Logging**:
   ```javascript
   // Add to background.js
   chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
     console.log('Message received:', request);
     // ... rest of code
   });
   ```

#### Swift App Debugging

1. **Console Logs**:
   ```bash
   # View live logs
   log stream --predicate 'process == "OctarineMenubar"'
   ```

2. **File System Monitoring**:
   ```bash
   # Watch for file creation
   fswatch ~/Documents/Octarine/clippings/
   ```

3. **Test File Operations**:
   ```swift
   // Add to ClippingManager.swift
   print("Saving to: \(fileURL.path)")
   print("Content length: \(content.count)")
   ```

4. **Monitor Distributed Notifications**:
   ```bash
   # Check if single-instance messaging is working
   log stream --predicate 'eventMessage contains "com.octarine.clipper.nativeMessage"'
   ```

### Performance Issues

#### Slow Content Extraction

**Symptoms**: Long delay before clip completes

**Solutions**:
1. Check page size (very long articles)
2. Disable unnecessary content script runs
3. Profile with Chrome DevTools
4. Consider timeout limits

#### High Memory Usage

**Symptoms**: App uses excessive memory

**Solutions**:
1. Limit recent clippings count
2. Check for memory leaks in Console
3. Restart app periodically
4. Profile with Instruments

### Specific Website Issues

#### Medium.com
- **Issue**: Lazy-loaded images
- **Solution**: Scroll through article first

#### GitHub
- **Issue**: Code blocks not preserving language
- **Solution**: Custom Turndown rule added for GitHub

#### News Sites
- **Issue**: Ads and popups interfering
- **Solution**: Readability.js handles most cases

### Error Messages

#### "Another instance is already running"
**Cause**: Single-instance architecture preventing duplicates
**Fix**: This is normal behavior - the message was forwarded to the existing instance

#### "Failed to parse message"
**Cause**: Malformed JSON from Chrome
**Fix**: Check content for unescaped quotes

#### "Directory creation failed"
**Cause**: Permissions issue
**Fix**: Manually create ~/Documents/Octarine/

#### "Native messaging host not found"
**Cause**: Manifest not installed correctly
**Fix**: Re-run install.sh

### Recovery Procedures

#### Reset Everything
```bash
# Kill any running instances
pkill OctarineMenubar
# Remove all data and settings
rm -rf ~/Documents/Octarine/
rm -f ~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/com.octarine.clipper.json
# Reinstall
./install.sh
```

#### Backup and Restore
```bash
# Backup
tar -czf octarine-backup.tar.gz ~/Documents/Octarine/

# Restore
tar -xzf octarine-backup.tar.gz -C ~/
```

### Getting Help

1. **Check Logs**:
   - Chrome: DevTools Console
   - Swift: Console.app or Terminal output

2. **Diagnostic Info**:
   ```bash
   # System info
   sw_vers
   
   # Chrome version
   /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version
   
   # Swift version
   swift --version
   ```

3. **File Bug Report** with:
   - macOS version
   - Chrome version
   - Error messages
   - Steps to reproduce

### Prevention

1. **Regular Updates**:
   - Keep Chrome updated
   - Update macOS
   - Pull latest code changes

2. **Monitoring**:
   - Check Console.app weekly
   - Monitor disk space
   - Test clipping periodically

3. **Backups**:
   - Time Machine includes Octarine folder
   - Consider git for daily notes
   - Export important clippings