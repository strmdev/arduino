#define RGBLED_RED_PIN   11
#define RGBLED_GREEN_PIN 9
#define RGBLED_BLUE_PIN  10

int redValue   = 0;
int greenValue = 0;
int blueValue  = 0;

void setup() {
    pinMode(RGBLED_RED_PIN, OUTPUT);
    pinMode(RGBLED_GREEN_PIN, OUTPUT);
    pinMode(RGBLED_BLUE_PIN, OUTPUT);
}

void loop() {
    redValue   = analogRead(A0);
    delay(200);
    greenValue = analogRead(A2);
    delay(200);
    blueValue  = analogRead(A1);
    delay(200);

    redValue   = redValue / 4;
    greenValue = greenValue / 4;
    blueValue  = blueValue / 4;

    analogWrite(RGBLED_RED_PIN, redValue);
    analogWrite(RGBLED_GREEN_PIN, greenValue);
    analogWrite(RGBLED_BLUE_PIN, blueValue);
}