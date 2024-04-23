#!/bin/bash

today=$(date +%F)
nowTime=$(date +%H%M%S_%3N)

if [ -d "./$today" ]; then
	echo "folder already exists"
else
	echo "Creating folder"
	mkdir ./"$today"
fi

echo $(rpicam-still -t 0.01 -o ./"$today"/"$nowTime".jpg)

create_date=$(date "+%Y-%m-%d %H:%M:%S.%3N%:z")
subject_distance=$(exiftool ./"$today"/"$nowTime".jpg | grep -i "Subject Distance" | awk -F ": " '{print $2}')
exposure_time=$(exiftool ./"$today"/"$nowTime".jpg | grep -i "Exposure Time" | awk -F ": " '{print $2}')
iso=$(exiftool ./"$today"/"$nowTime".jpg | grep -i "ISO" | awk -F ": " '{print $2}')

epoch=$(date +%s)
ms=$(date +%3N)

milli="$epoch.$ms"

json_data=$(cat <<EOF
{
  "File Name": "${nowTime}.jpg",
  "Create Date": "$create_date",
  "Create Seconds Epoch": "$milli",
  "Trigger": "Time",
  "Subject Distance": "$subject_distance",
  "Exposure Time": "$exposure_time",
  "ISO": "$iso"
}
EOF
)

echo "$json_data" > ./"$today"/"$nowTime".json
