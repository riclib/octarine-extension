/**
 * Background Service Worker for Octarine Extension
 * 
 * Handles:
 * - Keyboard shortcuts
 * - Communication with content scripts
 * - Native messaging to Swift app
 */

// Native messaging host name - must match the name in com.octarine.clipper.json
const NATIVE_HOST = 'com.octarine.clipper';

/**
 * Listen for keyboard shortcuts defined in manifest.json
 * Currently handles: clip-page (Cmd+Shift+S)
 */
chrome.commands.onCommand.addListener((command) => {
  if (command === 'clip-page') {
    clipCurrentPage();
  }
});

/**
 * Listen for messages from popup or content scripts
 * Handles async responses by returning true
 */
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'clip') {
    clipCurrentPage().then(sendResponse);
    return true; // Will respond asynchronously
  }
});

/**
 * Main function to clip the current active tab
 * 
 * Process:
 * 1. Gets the active tab
 * 2. Injects required scripts (Readability, Turndown, content script)
 * 3. Requests content extraction from content script
 * 4. Sends extracted data to native Swift app
 * 
 * @returns {Promise<Object>} Success status and message/error
 */
async function clipCurrentPage() {
  try {
    // Get the active tab
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
    
    // Inject content script if not already injected
    // This ensures our scripts are available even on pages loaded before extension
    await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      files: ['lib/Readability.js', 'lib/turndown.js', 'js/content.js']
    });
    
    // Send message to content script to extract content
    const response = await chrome.tabs.sendMessage(tab.id, { action: 'extractContent' });
    
    if (response.error) {
      return { success: false, error: response.error };
    }
    
    // Send to native app
    return sendToNativeApp(response.data);
  } catch (error) {
    console.error('Error clipping page:', error);
    return { success: false, error: error.message };
  }
}

/**
 * Sends extracted content to the native Swift app via Native Messaging
 * 
 * @param {Object} data - The clipping data to send
 * @param {string} data.type - Message type (always "clip")
 * @param {string} data.content - Markdown content
 * @param {Object} data.metadata - Metadata object with title, url, etc.
 * 
 * @returns {Promise<Object>} Response from native app or error
 * 
 * Note: Chrome's native messaging has a 1MB limit for messages
 */
function sendToNativeApp(data) {
  return new Promise((resolve) => {
    // Send message to native host
    // The native app must be registered in NativeMessagingHosts directory
    chrome.runtime.sendNativeMessage(NATIVE_HOST, data, (response) => {
      if (chrome.runtime.lastError) {
        console.error('Native messaging error:', chrome.runtime.lastError);
        resolve({ 
          success: false, 
          error: chrome.runtime.lastError.message 
        });
      } else {
        resolve({ 
          success: true, 
          message: response?.message || 'Page clipped successfully' 
        });
      }
    });
  });
}