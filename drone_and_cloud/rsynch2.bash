#!/bin/bash

# Define the target SSIDs
PRIORITY_SSID="EMLI-TEAM-23"
SECONDARY_SSID="Pixel"

# Define remote and local paths for rsync
REMOTE_PATH="jaflo18@10.0.0.10:/home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/"
LOCAL_PATH="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/images"

# Path to your Python GitHub script
PYTHON_GITHUB_SCRIPT="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/gitpush.py"

# Function to get the current WiFi SSID
current_ssid() {
    ssid=$(iwgetid -r)
    echo "$ssid"
}

# Function to check if a specific WiFi SSID is available
is_wifi_available() {
    local target_ssid="$1"
    nmcli -f ssid dev wifi list | grep -q "$target_ssid"
}

# Function to connect to a specific WiFi SSID
connect_to_wifi() {
    local target_ssid="$1"
    local password="$2"

    echo "Attempting to connect to $target_ssid..."
    nmcli dev wifi connect "$target_ssid" password "$password" ifname wlan0
}

# Function to prioritize WiFi networks
prioritize_wifi() {
    local priority_ssid="$1"
    local secondary_ssid="$2"

    local signal_strength=$(nmcli -f in-use,ssid,signal dev wifi | grep "^\*" | awk '{print $NF}')

    if [[ "$priority_ssid" == "$(current_ssid)" ]]; then
        if [[ "$signal_strength" -lt 30 ]]; then
            echo "Signal strength of $priority_ssid is under 30%. Connecting to $secondary_ssid..."
            connect_to_wifi "$secondary_ssid" "password_for_secondary_ssid"
            # Run the Python GitHub script if connected to the secondary SSID
            python3 "$PYTHON_GITHUB_SCRIPT"
        else
            echo "Connected to $priority_ssid with signal strength $signal_strength%. No action taken."
        fi
    elif is_wifi_available "$priority_ssid"; then
        connect_to_wifi "$priority_ssid" "password_for_priority_ssid"
    elif is_wifi_available "$secondary_ssid"; then
        connect_to_wifi "$secondary_ssid" "password_for_secondary_ssid"
        # Run the Python GitHub script if connected to the secondary SSID
        echo "Pushing to github"
        python3 "$PYTHON_GITHUB_SCRIPT"
    else
        echo "Neither $priority_ssid nor $secondary_ssid is available. Connecting to $secondary_ssid..."
        connect_to_wifi "$secondary_ssid" "password_for_secondary_ssid"
        echo "Pushing to github"
        python3 "$PYTHON_GITHUB_SCRIPT"
    fi
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
    # Ensure connection to the correct WiFi
    prioritize_wifi "$PRIORITY_SSID" "$SECONDARY_SSID"

    # If connected to the primary WiFi, proceed with synchronization
    if [[ "$(current_ssid)" == "$PRIORITY_SSID" ]]; then
        echo "Connected to $PRIORITY_SSID. Starting image synchronization..."
        sync_images_to_local
        update_json_metadata
        sync_back_to_remote
        echo "Synchronization completed."
    else
        echo "Not connected to $PRIORITY_SSID. No action taken."
    fi

    # Wait for 10 seconds before checking again
    sleep 10
done

