#!/bin/bash

today=$(date +%F)
nowTime=$(date +%H%M%S_%3N)

if [ -d "./$today" ]; then
	echo "folder already exists"
else
	echo "Creating folder"
	mkdir ./"$today"
fi

latest_image=$(ls -t ./"$today"/*.jpg | head -n1)

echo $(rpicam-still -t 0.01 -o ./"$today"/"$nowTime".jpg)

create_date=$(date "+%Y-%m-%d %H:%M:%S.%3N%:z")
subject_distance=$(exiftool ./"$today"/"$nowTime".jpg | grep -i "Subject Distance" | awk -F ": " '{print $2}')
exposure_time=$(exiftool ./"$today"/"$nowTime".jpg | grep -i "Exposure Time" | awk -F ": " '{print $2}')
iso=$(exiftool ./"$today"/"$nowTime".jpg | grep -i "ISO" | awk -F ": " '{print $2}')

epoch=$(date +%s)
ms=$(date +%3N)

milli="$epoch.$ms"

# Run the Python motion detection script and capture its output
if [ "$1" == "external" ]; then
  trigger="External"
else
  motion_detected=$(python3 motion_detect.py "$latest_image" ./"$today"/"$nowTime".jpg)

  # Determine the trigger based on motion detection
  if [ "$motion_detected" = "Motion detected" ]; then
      trigger="Motion"
  else
      trigger="Time"
  fi
fi


json_data=$(cat <<EOF
{
  "File Name": "${nowTime}.jpg",
  "Create Date": "$create_date",
  "Create Seconds Epoch": "$milli",
  "Trigger": "$trigger",
  "Subject Distance": "$subject_distance",
  "Exposure Time": "$exposure_time",
  "ISO": "$iso"
}
EOF
)

echo "$json_data" > ./"$today"/"$nowTime".json
