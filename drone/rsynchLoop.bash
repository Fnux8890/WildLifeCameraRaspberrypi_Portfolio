#!/bin/bash

# Define the target SSID
TARGET_SSID="YourTargetSSID"

# Define remote and local path for rsync
REMOTE_PATH="user@remote_host:/path/to/remote/images/"
LOCAL_PATH="/path/to/local/images/"

# Function to get the current WiFi SSID
current_ssid() {
    ssid=$(iwgetid -r)
    echo "$ssid"
}

# Function to perform rsync operation
sync_images() {
    rsync -avz --remove-source-files "$REMOTE_PATH" "$LOCAL_PATH"
}

# Infinite loop to check the connection and sync images
while true; do
    if [[ "$(current_ssid)" == "$TARGET_SSID" ]]; then
        echo "Connected to $TARGET_SSID. Starting image synchronization..."
        sync_images
        echo "Synchronization completed."
    else
        echo "Not connected to $TARGET_SSID. No action taken."
    fi
    # Wait for 10 seconds before checking again
    sleep 10
done
