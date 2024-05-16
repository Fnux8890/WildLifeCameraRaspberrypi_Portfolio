#!/bin/bash

# Define the directories and file paths
IMAGE_DIRECTORY="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/images"
OUTPUT_DIRECTORY="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/annotations"
PROCESSED_RECORDS="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/processed_records.txt"

# Path to your Python script
PYTHON_SCRIPT_PATH="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/update_images.py"

# Create output and records directories/files if they do not exist
mkdir -p "$OUTPUT_DIRECTORY"
touch "$PROCESSED_RECORDS"

# Function to check if an image has been processed
function is_processed {
    grep -Fxq "$1" "$PROCESSED_RECORDS"
}

# Function to mark an image as processed
function mark_processed {
    echo "$1" >> "$PROCESSED_RECORDS"
}

# Function to process images
function process_images {
    find "$IMAGE_DIRECTORY" -type f -name '*.jpg' | while read image_path; do
        if ! is_processed "$image_path"; then
            echo "Processing image: $image_path"
            # Call the Python script to process the image and update metadata
            python3 "$PYTHON_SCRIPT_PATH" "$image_path" "$OUTPUT_DIRECTORY" "$PROCESSED_RECORDS"
            # Mark the image as processed
            mark_processed "$image_path"
        else
            echo "Already processed: $image_path"
        fi
    done
}

# Process images continuously
while true; do
    process_images
    sleep 10  # Adjust the sleep duration as needed
done

