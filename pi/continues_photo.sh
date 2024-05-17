#!/bin/bash

TODAY=$(date +%F)
NOW_TIME=$(date +%H%M%S_%3N)
WORKING_DIRECTORY="/home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images_tmp/"
FINAL_DIRECTORY="/home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/$TODAY"
LOG_FILE="$WORKING_DIRECTORY/activity_log.txt"

# Ensure working directories exist
mkdir -m 777 -p $WORKING_DIRECTORY
mkdir -m 777 -p $FINAL_DIRECTORY

# Move current new to old before taking a new photo, if it exists
PREVIOUS_NEW=$(ls -t ${WORKING_DIRECTORY}/*_tmp_new.jpg 2>/dev/null | head -n1)
if [ -n "$PREVIOUS_NEW" ]; then
    # Remove existing _tmp_old files before renaming
    find $WORKING_DIRECTORY -type f -name '*_tmp_old*' -delete
    mv "${PREVIOUS_NEW}" "${PREVIOUS_NEW%_tmp_new.jpg}_tmp_old.jpg"
    mv "${PREVIOUS_NEW%_tmp_new.jpg}_tmp_new.json" "${PREVIOUS_NEW%_tmp_new.jpg}_tmp_old.json"
fi

# Taking a new photo
NEW_PHOTO_PATH="$WORKING_DIRECTORY/${NOW_TIME}_tmp_new.jpg"
rpicam-still -t 0.01 -o $NEW_PHOTO_PATH

# Create metadata JSON for the new photo
create_date=$(date "+%Y-%m-%d %H:%M:%S.%3N%:z")
subject_distance=$(exiftool $NEW_PHOTO_PATH | grep -i "Subject Distance" | awk -F ": " '{print $2}' | sed 's/ m$//')
exposure_time=$(exiftool $NEW_PHOTO_PATH | grep -i "Exposure Time" | awk -F ": " '{print $2}')
iso=$(exiftool $NEW_PHOTO_PATH | grep -i "ISO" | awk -F ": " '{print $2}')
epoch=$(date +%s)
ms=$(date +%3N)
milli="$epoch.$ms"

json_data=$(
    cat <<EOF
{
  "File Name": "${NOW_TIME}_tmp_new.jpg",
  "Create Date": "$create_date",
  "Create Seconds Epoch": "$milli",
  "Trigger": "",
  "Subject Distance": "$subject_distance",
  "Exposure Time": "$exposure_time",
  "ISO": "$iso"
}
EOF
)
echo "$json_data" >"${WORKING_DIRECTORY}/${NOW_TIME}_tmp_new.json"

# Run motion detection and handle triggers
if compgen -G "$WORKING_DIRECTORY*_tmp_old.jpg" >/dev/null; then
    LATEST_OLD=$(find "$WORKING_DIRECTORY" -maxdepth 1 -type f -name '*_tmp_old.jpg' -printf "%T+ %p\n" | sort -r | head -n 1 | cut -d" " -f2-)

    echo "Running motion detection script..." >>$LOG_FILE
    motion_detected=$(python3 /home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/motion_detect.py "$LATEST_OLD" "$NEW_PHOTO_PATH" 2>&1)
    echo "Motion detection script output: $motion_detected" >>$LOG_FILE

    if [ "$motion_detected" = "Motion detected" ]; then
        jq '.Trigger = "Motion"' "${WORKING_DIRECTORY}/${NOW_TIME}_tmp_new.json" >"${WORKING_DIRECTORY}/${NOW_TIME}_tmp_new.json.tmp"

        mv "${WORKING_DIRECTORY}/${NOW_TIME}_tmp_new.json.tmp" "${WORKING_DIRECTORY}/${NOW_TIME}_tmp_new.json"

        cp "${WORKING_DIRECTORY}/${NOW_TIME}_tmp_new.jpg" "${FINAL_DIRECTORY}/${NOW_TIME}.jpg"
        cp "${WORKING_DIRECTORY}/${NOW_TIME}_tmp_new.json" "${FINAL_DIRECTORY}/${NOW_TIME}.json"
    fi
fi

# Logging
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Script run complete. Motion detection status: $motion_detected" >>$LOG_FILE
