#!/bin/bash

# Define the target SSID
TARGET_SSID="EMLI-TEAM-23"

# Define remote and local path for rsync
REMOTE_PATH="jaflo18@10.0.0.10:/home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/"
LOCAL_PATH="/home/jeppe/Desktop/Drone/images"

# Function to get the current WiFi SSID
current_ssid() {
    ssid=$(iwgetid -r)
    echo "$ssid"
}

# Function to perform rsync operation
sync_images() {
    rsync -avz  "$REMOTE_PATH" "$LOCAL_PATH"
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
