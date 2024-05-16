# WildLifeCameraRaspberrypi_Portfolio

## Project struture
The repo consists of several foldes strutrued out to only handle specific domains of the porfolio. <br/>
```plaintext
Project Directory
│
├── Annotations
│   └── This folder holds the annotation JSON files that are generated from LLama
|       based on the images that the `cloud` receives.
│
├── Cloud
│   └── This folder holds the cloud code that handles the Annotations and git pushes.
│
├── Drone
│   └── This folder holds the Drone scripts for connecting to the
|       `wildlife camera` and initiating the cloud procedures.
│
├── Pi
│   └── This folder holds the scripts that run on the `wildlife camera`.
|       This includes communication with the esp32, Pi, and the functionality of the camera.
│
├── Esp32 # Note that the actual esp device is ESP8266
│   └── This folder holds the scripts for the ESP8266, handling external trigger functionality.
│
└── Pico
    └── This folder holds the scripts for the Pico that manage the wiper functionality.
```


## Porfolio task outline
### Pi
- [x] Done?

The wildlife camera linux system is your Raspberry Pi with a Raspberry Pi Camera Module 3. 

Please follow the installation instructions under Extra components. You can then test the camera using the command:

`$rpicam-still -t 0.01 -o test.jpg`

To perform motion detection you may use the script motion_detect.py available on itslearning.

### Pico
- [x] Done?

The camera is connected via USB to the Raspberry Pi which acts as rain sensor (simulated by press of the onboard BOOTSEL botton) and camera lens screen wiper (simulated by a servo performing a wiping movement).

Connect the servo to the following Raspberry Pico pins
    Servo red wire to pin VBUS
    Servo brown wire to pin GND
    Servo orange wire to pin 15

At itslearning you will find an Arduino Sketch for the Raspberry Pico which you must use without edits.

Please make sure that you use the boards file Raspberry Pi Pico/2040 from [Earlephilpower](https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json)

Please also make sure that you use the ArduinoJSON library from Bernoit Blanken.

If not, you may get errors when compiling the Arduino sketch.

The Arduino sketch will continuously output a JSON object of the format:
`{'wiper_angle': 0, 'rain_detect': 0}`
and it accepts a JSON object as input if formatted as:
`{'wiper_angle': 180}`
where the angle is between 0 and 180.
If you send an angle outside 0-180, you will receive:
`{'serial': 'angle_error'}`
If you send erroneous JSON data, you will receive:
`{'serial': 'json_error'}`

### Esp32
- [x] Done?

The external wildlife trigger is the ESP8266 connected to the wildlife camera WiFi access point. The trigger mechanism is a ground wire and a digital input wire that simulate an animal walking above a pressure plate causing a short circuit of the wires (you may use an external button).

Modify the Arduino sketch esp8266_count_mqtt.ino from module 7 to send data immediately when a short circuit (button press) is detected.

### Drone
- [x] Done?

The drone is simulated by you linux desktop environment on your laptop.

During drone flight your laptop should be disconnected from the internet and a "drone flight" script should use the laptop WiFi to search for nearby cameras by means of the WiFi SSID.

When a camera WiFi SSID is found, the laptop should offload any new photos of from the wildlife camera.

The drone flight is terminated by manually stopping the drone flight script and connecting the WiFi to internet.

### Cloud







