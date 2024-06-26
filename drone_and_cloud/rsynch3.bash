#!/bin/bash

# target SSIDs
PRIORITY_SSID="EMLI-TEAM-23"
SECONDARY_SSID="Pixel"

#  remote and local paths for rsync
REMOTE_PATH="jaflo18@10.0.0.10:/home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/"
LOCAL_PATH="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/images"


PYTHON_GITHUB_SCRIPT="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/gitpush.py"


current_ssid() {
    ssid=$(iwgetid -r)
    echo "$ssid"
}

set_time_on_ap() {
    local ap_ip="10.0.0.10" 
    local current_time=$(date +"%Y-%m-%d %T")
    echo "Setting time on AP to $current_time..."
    ssh -i /home/username/.ssh/id_rsa jaflo18@10.0.0.10 "sudo date -s '$current_time'"
}

# check if SSID is available
is_wifi_available() {
    local target_ssid="$1"
    nmcli -f ssid dev wifi list | grep -q "$target_ssid"
}

# connect to  SSID
connect_to_wifi() {
    local target_ssid="$1"
    local password="$2"

    echo "Attempting to connect to $target_ssid..."
    nmcli dev wifi connect "$target_ssid" password "$password" ifname wlan0
}

# prioritize Wildlife AP network
prioritize_wifi() {
    local priority_ssid="$1"
    local secondary_ssid="$2"

    local signal_strength=$(nmcli -f in-use,ssid,signal dev wifi | grep "^\*" | awk '{print $NF}')

    if [[ "$priority_ssid" == "$(current_ssid)" ]]; then
        if [[ "$signal_strength" -lt 30 ]]; then
            echo "Signal strength of $priority_ssid is under 30%. Connecting to $secondary_ssid..."
            connect_to_wifi "$secondary_ssid" "password_for_secondary_ssid"
            python3 "$PYTHON_GITHUB_SCRIPT"
        else
            echo "Connected to $priority_ssid with signal strength $signal_strength%. No action taken."
        fi
    elif is_wifi_available "$priority_ssid"; then
        connect_to_wifi "$priority_ssid" "password_for_priority_ssid"
    elif is_wifi_available "$secondary_ssid"; then
        connect_to_wifi "$secondary_ssid" "password_for_secondary_ssid"
        echo "Pushing to github"
        python3 "$PYTHON_GITHUB_SCRIPT"
    else
        echo "Neither $priority_ssid nor $secondary_ssid is available. Connecting to $secondary_ssid..."
        connect_to_wifi "$secondary_ssid" "password_for_secondary_ssid"
        echo "Pushing to github"
        python3 "$PYTHON_GITHUB_SCRIPT"
    fi
}

#rsync operation to sync images 
sync_images_to_local() {
    rsync -avz "$REMOTE_PATH" "$LOCAL_PATH"
}

# update JSON metadata
update_json_metadata() {
    find "$LOCAL_PATH" -type f -name '*.json' -exec python3 update_json.py {} \;
}

#sync modified files back to remote
sync_back_to_remote() {
    rsync -avz "$LOCAL_PATH"/ "$REMOTE_PATH"
}


while true; do
    prioritize_wifi "$PRIORITY_SSID" "$SECONDARY_SSID"

    # If connected to primary WiFi then sync
    if [[ "$(current_ssid)" == "$PRIORITY_SSID" ]]; then
        echo "Connected to $PRIORITY_SSID. Starting image synchronization..."
        sync_images_to_local
        update_json_metadata
        sync_back_to_remote
        echo "Synchronization completed."
    else
        echo "Not connected to $PRIORITY_SSID. No action taken."
    fi

    sleep 10
done
