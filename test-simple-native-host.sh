#!/bin/bash
# Simple native messaging host for testing

# Log that we were called
echo "Native host started with args: $@" >> ~/octarine-native-test.log

# Read the message length (4 bytes)
read -n 4 length_bytes

# Convert to integer (this is simplified, may not work for all cases)
length=$(printf "%d" "'${length_bytes:0:1}")

# Read the message
read -n $length message

# Log what we received
echo "Received message of length $length: $message" >> ~/octarine-native-test.log

# Send a simple response
response='{"success":true,"message":"Test response"}'
length=${#response}

# Write length (4 bytes) and response
printf "\\x$(printf '%02x' $((length & 0xFF)))"
printf "\\x$(printf '%02x' $(((length >> 8) & 0xFF)))"
printf "\\x$(printf '%02x' $(((length >> 16) & 0xFF)))"
printf "\\x$(printf '%02x' $(((length >> 24) & 0xFF)))"
printf "%s" "$response"