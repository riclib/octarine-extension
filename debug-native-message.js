// Enhanced debugging for the extension
// Add this to the top of background.js temporarily

const originalSendNativeMessage = chrome.runtime.sendNativeMessage;

chrome.runtime.sendNativeMessage = function(application, message, responseCallback) {
  console.log('🔍 [Native Message Debug]');
  console.log('  Application:', application);
  console.log('  Message:', message);
  console.log('  Message size:', JSON.stringify(message).length, 'bytes');
  
  const startTime = Date.now();
  
  originalSendNativeMessage.call(chrome.runtime, application, message, function(response) {
    const duration = Date.now() - startTime;
    console.log('  Duration:', duration, 'ms');
    
    if (chrome.runtime.lastError) {
      console.error('  ❌ Error:', chrome.runtime.lastError);
      console.error('  Error type:', typeof chrome.runtime.lastError);
      console.error('  Error keys:', Object.keys(chrome.runtime.lastError));
      console.error('  Error JSON:', JSON.stringify(chrome.runtime.lastError));
      
      // Try to get more details
      const error = chrome.runtime.lastError;
      if (error.message) {
        console.error('  Error message:', error.message);
      }
      if (error.code) {
        console.error('  Error code:', error.code);
      }
    } else {
      console.log('  ✅ Success! Response:', response);
    }
    
    if (responseCallback) {
      responseCallback(response);
    }
  });
};