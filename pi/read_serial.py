#!/usr/bin/env python3
import time
import serial
import json
import paho.mqtt.client as mqtt

ser = None

def on_message(client, userdata, message):
    topic = message.topic
    payload = message.payload.decode('utf-8')
    print("Received message on topic:", topic)
    print("Message:", payload)
    if topic == "wipe":
        try:
            send_serial_command()
            print("Sent command")
        except json.JSONDecodeError:
            print("Invalid JSON received from MQTT")

def send_serial_command():
    global ser
    ser.write(json.dumps({'wiper_angle': 179}).encode('utf-8'))
    ser.write(json.dumps({'wiper_angle': 1}).encode('utf-8'))

def main():
    global ser
    mqtt_username = "jaflo18"
    mqtt_password = "avd85hfk"

    client = mqtt.Client(client_id="",
                         transport="tcp",
                         protocol=mqtt.MQTTv311,
                         clean_session=True)
    client.on_message = on_message
    client.username_pw_set(username=mqtt_username, password=mqtt_password)

    client.connect("localhost", 1883)
    client.subscribe("wipe")

    ser = serial.Serial(
        port='/dev/ttyACM0',
        baudrate = 115200,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        timeout=1
        )

    client.loop_start()

    while True:
        x = ser.readline().decode('utf-8').strip()
        print("Received from serial:", x)
        if x:
            try:
                data = json.loads(x)
                rain_detect = data.get('rain_detect')
                if rain_detect == 1:
                    client.publish("command", "wipe")
                    print("Sent wipe command to MQTT")
            except json.JSONDecodeError:
                print("Invalid JSON received from serial")

if __name__ == "__main__":
    main()
