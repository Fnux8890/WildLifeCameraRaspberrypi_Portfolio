

// Embedded Linux (EMLI)
// University of Southern Denmark

// 2022-03-24, Kjeld Jensen, First version

// Configuration
#define WIFI_SSID       "EMLI-TEAM-23"
#define WIFI_PASSWORD    "emliemli"

#define MQTT_SERVER      "192.168.10.1"
#define MQTT_SERVERPORT  1883 
#define MQTT_USERNAME    "jaflo18"
#define MQTT_KEY         "avd85hfk"
#define MQTT_TOPIC       "/external"  

// wifi
#include <ESP8266WiFiMulti.h>
#include <ESP8266HTTPClient.h>
ESP8266WiFiMulti WiFiMulti;
const uint32_t conn_tout_ms = 5000;

// counter
#define GPIO_INTERRUPT_PIN 4
#define DEBOUNCE_TIME 100 
volatile unsigned long count_prev_time;
volatile unsigned long count;

// mqtt
#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"
WiFiClient wifi_client;
Adafruit_MQTT_Client mqtt(&wifi_client, MQTT_SERVER, MQTT_SERVERPORT, MQTT_USERNAME, MQTT_KEY);
Adafruit_MQTT_Publish count_mqtt_publish = Adafruit_MQTT_Publish(&mqtt, MQTT_USERNAME MQTT_TOPIC);

ICACHE_RAM_ATTR void count_isr()
{
  if (count_prev_time + DEBOUNCE_TIME < millis() || count_prev_time > millis())
  {
    count_prev_time = millis(); 
    count++;
  }
}

void debug(const char *s)
{
  Serial.print (millis());
  Serial.print (" ");
  Serial.println(s);
}

void mqtt_connect()
{
  int8_t ret;

  // Stop if already connected.
  if (! mqtt.connected())
  {
    debug("Connecting to MQTT... ");
    while ((ret = mqtt.connect()) != 0)
    { // connect will return 0 for connected
         Serial.println(mqtt.connectErrorString(ret));
         debug("Retrying MQTT connection in 5 seconds...");
         mqtt.disconnect();
         delay(5000);  // wait 5 seconds
    }
    debug("MQTT Connected");
  }
}

void print_wifi_status()
{
  Serial.print (millis());
  Serial.print(" WiFi connected: ");
  Serial.print(WiFi.SSID());
  Serial.print(" ");
  Serial.print(WiFi.localIP());
  Serial.print(" RSSI: ");
  Serial.print(WiFi.RSSI());
  Serial.println(" dBm");
}

void setup()
{
  // count
  count_prev_time = millis();
  count = 0;
  pinMode(GPIO_INTERRUPT_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(GPIO_INTERRUPT_PIN), count_isr, RISING);

  // serial
  Serial.begin(115200);
  delay(10);
  debug("Boot");

  // wifi
  WiFi.persistent(false);
  WiFi.mode(WIFI_STA);
  WiFiMulti.addAP(WIFI_SSID, WIFI_PASSWORD);
  if(WiFiMulti.run(conn_tout_ms) == WL_CONNECTED)
  {
    print_wifi_status();
  }
  else
  {
    debug("Unable to connect");
  }
}

void publish_data()
{
  count = 0;

  Serial.println(" Connecting...");
  if((WiFiMulti.run(conn_tout_ms) == WL_CONNECTED))
  {
    print_wifi_status();
  
    mqtt_connect();
    if (! count_mqtt_publish.publish("external"))
    {
      debug("MQTT failed");
    }
    else
    {
      debug("MQTT ok");
    }
  }
}

void loop()
{
    if (count > 0)
    {
      Serial.print("Publishing data from loop\n");
      publish_data();
    }
}
