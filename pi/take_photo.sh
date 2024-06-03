#!/bin/bash

today=$(date +%F)
nowTime=$(date +%H%M%S_%3N)

if [ -d "/home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/$today" ]; then
	echo "folder already exists"
else
	echo "Creating folder"
	mkdir -m 777 "/home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/$today" && chown jaflo18:jaflo18 "/home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/$today"
fi

echo $(rpicam-still -t 0.01 -o /home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/"$today"/"$nowTime".jpg)

create_date=$(date "+%Y-%m-%d %H:%M:%S.%3N%:z")
subject_distance=$(exiftool /home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/"$today"/"$nowTime".jpg | grep -i "Subject Distance" | awk -F ": " '{print $2}' | sed 's/ m$//')
exposure_time=$(exiftool /home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/"$today"/"$nowTime".jpg | grep -i "Exposure Time" | awk -F ": " '{print $2}')
iso=$(exiftool /home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/"$today"/"$nowTime".jpg | grep -i "ISO" | awk -F ": " '{print $2}')

epoch=$(date +%s)
ms=$(date +%3N)

milli="$epoch.$ms"

echo "$1"
#If the script is called with external the trigger is external and vice versa for other triggers
if [ "$1" == "external" ]; then
  trigger="External"

elif [ "$1" == "time" ]; then
  trigger="Time"  
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

echo "$json_data" > /home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/"$today"/"$nowTime".json
cp -r "/home/jaflo18/exam/WildLifeCameraRaspberrypi_Portfolio/pi/images/$today" "/var/www/html/images/"
