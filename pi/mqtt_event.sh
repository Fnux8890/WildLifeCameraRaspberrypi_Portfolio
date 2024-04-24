#!/bin/bash


# MQTT broker settings

HOST="localhost"
USER="jaflo18"
TOPIC="$USER/external"
PORT="1883"
PASS="avd85hfk"


SCRIPT_PATH="./take_photo.sh external"

# PAYLOAD=$(mosquitto_sub -d -h $HOST -p $PORT -u $USER -P $PASS -t $TOPIC) 
# echo "message: $PAYLOAD"

mosquitto_sub -d -h $HOST -p $PORT -u $USER -P $PASS -t $TOPIC | while read payload
do
    echo "Recived message: $payload"

    # # Check for specific condition
    if [[ "$payload" == "external" ]]; then
        echo "Condition met, executing script..."
        $SCRIPT_PATH
    fi
done 