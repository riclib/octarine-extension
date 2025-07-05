#!/usr/bin/env python3
import json
import struct
import sys
import subprocess

# Test message that mimics what the extension would send
test_message = {
    "type": "clip",
    "content": "# Test Article\n\nThis is a test clipping to verify native messaging is working.",
    "metadata": {
        "title": "Test Article",
        "url": "https://example.com/test",
        "author": "Test Author",
        "keywords": ["test", "native-messaging"],
        "date": "2024-07-06T01:00:00Z",
        "excerpt": "This is a test excerpt"
    }
}

# Encode the message
message_json = json.dumps(test_message)
message_bytes = message_json.encode('utf-8')

# Native messaging protocol: 4-byte length header (little-endian) + message
length_bytes = struct.pack('<I', len(message_bytes))

# Run the native app with Chrome extension origin
try:
    proc = subprocess.Popen(
        ['/Applications/OctarineMenubar.app/Contents/MacOS/OctarineMenubar',
         'chrome-extension://ccpoplhmbhhjaileoijblcocnhonmmch/'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    
    # Send the message
    proc.stdin.write(length_bytes + message_bytes)
    proc.stdin.flush()
    
    # Wait for response (with timeout)
    stdout, stderr = proc.communicate(timeout=5)
    
    if stdout:
        # Parse response (4-byte length + JSON)
        if len(stdout) >= 4:
            response_length = struct.unpack('<I', stdout[:4])[0]
            response_json = stdout[4:4+response_length].decode('utf-8')
            response = json.loads(response_json)
            print("Response:", json.dumps(response, indent=2))
        else:
            print("Response too short:", stdout)
    
    if stderr:
        print("Stderr:", stderr.decode('utf-8'))
        
except subprocess.TimeoutExpired:
    print("Timeout: No response from native app within 5 seconds")
    proc.kill()
except Exception as e:
    print(f"Error: {e}")