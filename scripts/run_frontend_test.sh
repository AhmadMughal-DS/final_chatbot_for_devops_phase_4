#!/bin/bash

echo "Starting Frontend Chat Test..."

# Set display for headless Chrome
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 &

# Wait for Xvfb to start
sleep 5

# Run the test
python3 tests/test_frontend_chat_headless.py

echo "Frontend Chat Test completed!"
