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

# Function to perform rsync operation to sync images from remote to local
sync_images_to_local() {
    rsync -avz "$REMOTE_PATH" "$LOCAL_PATH"
}

# Function to update JSON metadata using Python
update_json_metadata() {
    find "$LOCAL_PATH" -type f -name '*.json' -exec python3 update_json.py {} \;
}

# Function to sync modified files back to remote
sync_back_to_remote() {
    rsync -avz "$LOCAL_PATH"/ "$REMOTE_PATH"
}

# Infinite loop to check the connection and sync images
while true; do
    if [[ "$(current_ssid)" == "$TARGET_SSID" ]]; then
        echo "Connected to $TARGET_SSID. Starting image synchronization..."
        sync_images_to_local
        update_json_metadata
        sync_back_to_remote
        echo "Synchronization completed."
    else
        echo "Not connected to $TARGET_SSID. No action taken."
    fi
    # Wait for 10 seconds before checking again
    sleep 10
done
