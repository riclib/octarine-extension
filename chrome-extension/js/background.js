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
    handleClip();
  }
});

/**
 * Listen for clicks on the extension icon
 */
chrome.action.onClicked.addListener((tab) => {
  handleClip();
});

/**
 * Handle the clipping process with visual feedback
 */
async function handleClip() {
  // Show "working" badge
  chrome.action.setBadgeText({ text: '...' });
  chrome.action.setBadgeBackgroundColor({ color: '#4285f4' });
  
  try {
    const result = await clipCurrentPage();
    
    if (result.success) {
      // Success feedback
      chrome.action.setBadgeText({ text: '✓' });
      chrome.action.setBadgeBackgroundColor({ color: '#0f9d58' });
      
      // Clear badge after 2 seconds
      setTimeout(() => {
        chrome.action.setBadgeText({ text: '' });
      }, 2000);
    } else {
      // Error feedback
      chrome.action.setBadgeText({ text: '!' });
      chrome.action.setBadgeBackgroundColor({ color: '#ea4335' });
      
      // Show error notification
      chrome.notifications.create({
        type: 'basic',
        iconUrl: 'images/icon48.png',
        title: 'Clipping Failed',
        message: result.error || 'Unknown error occurred'
      });
      
      // Clear badge after 3 seconds
      setTimeout(() => {
        chrome.action.setBadgeText({ text: '' });
      }, 3000);
    }
  } catch (error) {
    console.error('Clip error:', error);
    chrome.action.setBadgeText({ text: '!' });
    chrome.action.setBadgeBackgroundColor({ color: '#ea4335' });
    
    setTimeout(() => {
      chrome.action.setBadgeText({ text: '' });
    }, 3000);
  }
}

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
    
    // Try to send message to content script first
    try {
      const response = await chrome.tabs.sendMessage(tab.id, { action: 'extractContent' });
      
      if (response.error) {
        return { success: false, error: response.error };
      }
      
      // Send to native app
      return sendToNativeApp(response.data);
    } catch (messageError) {
      // Content script not loaded, inject it
      console.log('Content script not loaded, injecting...');
      
      // Check if scripting API is available
      if (!chrome.scripting) {
        console.error('Scripting API not available. Please reload the extension.');
        return { success: false, error: 'Scripting API not available. Please reload the extension in chrome://extensions' };
      }
      
      // Inject content script
      await chrome.scripting.executeScript({
        target: { tabId: tab.id },
        files: ['lib/Readability.js', 'lib/turndown.js', 'js/content.js']
      });
      
      // Wait a bit for scripts to load
      await new Promise(resolve => setTimeout(resolve, 100));
      
      // Try again
      const response = await chrome.tabs.sendMessage(tab.id, { action: 'extractContent' });
      
      if (response.error) {
        return { success: false, error: response.error };
      }
      
      // Send to native app
      return sendToNativeApp(response.data);
    }
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