document.addEventListener('DOMContentLoaded', () => {
  const clipButton = document.getElementById('clipButton');
  const statusDiv = document.getElementById('status');
  
  clipButton.addEventListener('click', async () => {
    clipButton.disabled = true;
    statusDiv.textContent = 'Clipping...';
    statusDiv.className = 'status';
    
    try {
      const response = await chrome.runtime.sendMessage({ action: 'clip' });
      
      if (response.success) {
        statusDiv.textContent = 'Page clipped successfully!';
        statusDiv.className = 'status success';
        
        // Close popup after 1.5 seconds
        setTimeout(() => {
          window.close();
        }, 1500);
      } else {
        statusDiv.textContent = response.error || 'Failed to clip page';
        statusDiv.className = 'status error';
        clipButton.disabled = false;
      }
    } catch (error) {
      statusDiv.textContent = 'Error: ' + error.message;
      statusDiv.className = 'status error';
      clipButton.disabled = false;
    }
  });
});