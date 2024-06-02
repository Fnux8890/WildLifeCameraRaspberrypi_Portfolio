#!/bin/bash


IMAGE_DIRECTORY="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/images"
OUTPUT_DIRECTORY="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/annotations"
PROCESSED_RECORDS="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/processed_records.txt"

PYTHON_SCRIPT_PATH="/home/jeppe/Desktop/WildLifeCameraRaspberrypi_Portfolio/drone_and_cloud/update_images.py"


mkdir -p "$OUTPUT_DIRECTORY"
touch "$PROCESSED_RECORDS"


function is_processed {
    grep -Fxq "$1" "$PROCESSED_RECORDS"
}

#mark an image as processed
function mark_processed {
    echo "$1" >> "$PROCESSED_RECORDS"
}

#  process images
function process_images {
    find "$IMAGE_DIRECTORY" -type f -name '*.jpg' | while read image_path; do
        if ! is_processed "$image_path"; then
            echo "Processing image: $image_path"
            python3 "$PYTHON_SCRIPT_PATH" "$image_path" "$OUTPUT_DIRECTORY" "$PROCESSED_RECORDS"
            mark_processed "$image_path"
        else
            echo "Already processed: $image_path"
        fi
    done
}


while true; do
    process_images
    sleep 10  
done

