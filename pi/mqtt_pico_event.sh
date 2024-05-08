#!/bin/bash

SCRIPT_PATH="./take_photo.sh external"

mosquitto_sub -d -h localhost -p 1883 -u jaflo18 -P avd85hfk -t command | while read payload
do
    echo "Recived message: $payload"

    # # Check for specific condition
    if [[ "$payload" == "wipe" ]]; then
        echo "Condition met, executing script..."
        echo $(./pico_post.sh)
    fi
done 
