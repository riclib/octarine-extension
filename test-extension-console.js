// Test script to run in the extension's background console
// Open chrome://extensions/, click on the extension's "service worker" link
// Then paste and run this code in the console

console.log('=== Testing Octarine Native Messaging ===');

// Test 1: Check if native messaging API is available
console.log('1. Native messaging API available:', typeof chrome.runtime.sendNativeMessage);

// Test 2: Send a simple test message
console.log('2. Sending test message to native host...');
chrome.runtime.sendNativeMessage('com.octarine.clipper', 
  {
    type: 'clip',
    content: '# Test Message\n\nThis is a test from the extension console.',
    metadata: {
      title: 'Console Test',
      url: 'chrome-extension://test',
      date: new Date().toISOString()
    }
  }, 
  response => {
    if (chrome.runtime.lastError) {
      console.error('❌ Native messaging error:', chrome.runtime.lastError);
      console.error('Error details:', JSON.stringify(chrome.runtime.lastError));
    } else {
      console.log('✅ Success! Response:', response);
    }
  }
);

// Test 3: Check permissions
console.log('3. Checking extension permissions...');
chrome.permissions.getAll(permissions => {
  console.log('Granted permissions:', permissions);
});

// Test 4: Try the actual clip function
console.log('4. Testing the clipCurrentPage function...');
if (typeof clipCurrentPage === 'function') {
  clipCurrentPage().then(result => {
    console.log('Clip result:', result);
  }).catch(err => {
    console.error('Clip error:', err);
  });
} else {
  console.log('clipCurrentPage function not found in this context');
}